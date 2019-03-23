# Copyright, 2018, by Samuel G. D. Williams. <http://www.codeotaku.com>
# 
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
# 
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.

require_relative 'statistics'
require_relative 'wrapper'

require 'event/terminal'

module Covered
	class Summary
		def initialize(threshold: 1.0)
			@threshold = threshold
		end
		
		def terminal(output)
			Event::Terminal.for(output).tap do |terminal|
				terminal[:path] ||= terminal.style(nil, nil, :bold, :underline)
				terminal[:brief_path] ||= terminal.style(:yellow)
				
				terminal[:uncovered_prefix] ||= terminal.style(:red)
				terminal[:covered_prefix] ||= terminal.style(:green)
				terminal[:ignored_prefix] ||= terminal.style(nil, nil, :faint)
				
				terminal[:uncovered_code] ||= terminal.style(:red)
				terminal[:covered_code] ||= terminal.style(:green)
				terminal[:ignored_code] ||= terminal.style(nil, nil, :faint)
				
				terminal[:annotations] ||= terminal.style(:blue)
			end
		end
		
		def each(wrapper)
			statistics = Statistics.new
			
			wrapper.each do |coverage|
				statistics << coverage
				
				if @threshold.nil? or coverage.ratio < @threshold
					yield coverage
				end
			end
			
			return statistics
		end
		
		def print_annotations(terminal, coverage, line, line_offset)
			if annotations = coverage.annotations[line_offset]
				prefix = "#{line_offset}|".rjust(8) + "*|".rjust(8)
				terminal.write prefix, style: :ignored_prefix
				
				terminal.write line.match(/^\s+/)
				terminal.puts "\# #{annotations.join(", ")}", style: :annotations
			end
		end
		
		def print_line_header(terminal)
			terminal.write "Line|".rjust(8)
			terminal.puts "Hits|".rjust(8)
		end
		
		def print_line(terminal, line, line_offset, count)
			prefix = "#{line_offset}|".rjust(8) + "#{count}|".rjust(8)
			
			if count == nil
				terminal.write prefix, style: :ignored_prefix
				terminal.write line, style: :ignored_code
			elsif count == 0
				terminal.write prefix, style: :uncovered_prefix
				terminal.write line, style: :uncovered_code
			else
				terminal.write prefix, style: :covered_prefix
				terminal.write line, style: :covered_code
			end
			
			# If there was no newline at end of file, we add one:
			unless line.end_with? $/
				terminal.puts
			end
		end
		
		# A coverage array gives, for each line, the number of line execution by the interpreter. A nil value means coverage is disabled for this line (lines like else and end).
		def call(wrapper, output = $stdout)
			terminal = self.terminal(output)
			
			statistics = self.each(wrapper) do |coverage|
				line_offset = 1
				
				path = wrapper.relative_path(coverage.path)
				terminal.puts ""
				terminal.puts path, style: :path
				
				counts = coverage.counts
				
				coverage.read do |file|
					print_line_header(terminal)
					
					file.each_line do |line|
						count = counts[line_offset]
						
						print_annotations(terminal, coverage, line, line_offset)
						
						print_line(terminal, line, line_offset, count)
						
						line_offset += 1
					end
				end
				
				coverage.print(output)
			end
			
			statistics.print(output)
		end
	end
	
	class BriefSummary < Summary
		def call(wrapper, output = $stdout, before: 4, after: 4)
			terminal = self.terminal(output)
			
			ordered = []
			
			statistics = self.each(wrapper) do |coverage|
				ordered << coverage unless coverage.complete?
			end
			
			terminal.puts
			statistics.print(output)
			
			if ordered.any?
				terminal.puts "", "Least Coverage:"
				ordered.sort_by!(&:missing_count).reverse!
				
				ordered.first(5).each do |coverage|
					path = wrapper.relative_path(coverage.path)
					
					terminal.write path, style: :brief_path
					terminal.puts ": #{coverage.missing_count} lines not executed!"
				end
			end
		end
	end
	
	class PartialSummary < Summary
		def call(wrapper, output = $stdout, before: 4, after: 4)
			terminal = self.terminal(output)
			
			statistics = self.each(wrapper) do |coverage|
				line_offset = 1
				
				path = wrapper.relative_path(coverage.path)
				terminal.puts ""
				terminal.puts path, style: :path
				
				counts = coverage.counts
				last_line = nil
				
				unless coverage.zero?
					print_line_header(terminal)
					
					coverage.read do |file|
						file.each_line do |line|
							range = Range.new([line_offset - before, 0].max, line_offset+after)
							
							if counts[range]&.include?(0)
								count = counts[line_offset]
								
								if last_line and last_line != line_offset-1
									terminal.puts ":".rjust(16)
								end
								
								print_annotations(terminal, coverage, line, line_offset)
								print_line(terminal, line, line_offset, count)
								
								last_line = line_offset
							end
							
							line_offset += 1
						end
					end
				end
				
				coverage.print(output)
			end
			
			terminal.puts
			statistics.print(output)
		end
	end
end
