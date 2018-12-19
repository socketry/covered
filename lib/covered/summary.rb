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

require 'rainbow'

module Covered
	class Summary < Wrapper
		def initialize(output, threshold: 1.0)
			super(output)
			
			@statistics = nil
			
			@threshold = threshold
		end
		
		def each
			@statistics = Statistics.new
			
			super do |coverage|
				@statistics << coverage
				
				if @theshold.nil? or coverage.ratio < @threshold
					yield coverage
				end
			end
		end
		
		def print_annotations(output, coverage, line, line_offset)
			if annotations = coverage.annotations[line_offset]
				output.write("#{line_offset}|".rjust(8))
				output.write("*|".rjust(8))
				
				output.write line.match(/^\s+/)
				output.write '# '
				
				output.puts Rainbow(annotations.join(", ")).bright
			end
		end
		
		# A coverage array gives, for each line, the number of line execution by the interpreter. A nil value means coverage is disabled for this line (lines like else and end).
		def print_summary(output = $stdout)
			self.each do |coverage|
				line_offset = 1
				output.puts "", Rainbow(coverage.path).bold.underline
				
				counts = coverage.counts
				
				File.open(coverage.path, "r") do |file|
					file.each_line do |line|
						count = counts[line_offset]
						
						print_annotations(output, coverage, line, line_offset)
						
						output.write("#{line_offset}|".rjust(8))
						output.write("#{count}|".rjust(8))
						
						if count == nil
							output.write Rainbow(line).faint
						elsif count == 0
							output.write Rainbow(line).red
						else
							output.write Rainbow(line).green
						end
						
						# If there was no newline at end of file, we add one:
						unless line.end_with? $/
							output.puts
						end
						
						line_offset += 1
					end
				end
				
				coverage.print_summary(output)
			end
			
			@statistics.print_summary(output)
		end
	end
	
	class PartialSummary < Summary
		def print_summary(output = $stdout, before: 4, after: 4)
			statistics = Statistics.new
			
			self.each do |coverage|
				line_offset = 1
				output.puts "", Rainbow(coverage.path).bold.underline
				
				counts = coverage.counts
				last_line = nil
				
				File.open(coverage.path, "r") do |file|
					file.each_line do |line|
						range = Range.new([line_offset - before, 0].max, line_offset+after)
						
						if counts[range]&.include?(0)
							count = counts[line_offset]
							
							if last_line and last_line != line_offset-1
								output.puts ":".rjust(16)
							end
							
							print_annotations(output, coverage, line, line_offset)
							
							prefix = "#{line_offset}|".rjust(8) + "#{count}|".rjust(8)
							
							if count == nil
								output.write prefix
								output.write Rainbow(line).faint
							elsif count == 0
								output.write Rainbow(prefix).background(:darkred)
								output.write Rainbow(line).red
							else
								output.write Rainbow(prefix).background(:darkgreen)
								output.write Rainbow(line).green
							end
							
							# If there was no newline at end of file, we add one:
							unless line.end_with? $/
								output.puts
							end
							
							last_line = line_offset
						end
						
						line_offset += 1
					end
				end
				
				coverage.print_summary(output)
			end
			
			output.puts
			@statistics.print_summary(output)
		end
	end
end
