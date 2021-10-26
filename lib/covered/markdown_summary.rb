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

require 'console/output'

module Covered
	class MarkdownSummary
		def initialize(threshold: 1.0)
			@threshold = threshold
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
		
		def print_annotations(output, coverage, line, line_offset)
			if annotations = coverage.annotations[line_offset]
				prefix = "#{line_offset}|".rjust(8) + "*|".rjust(8)
				output.write prefix
				
				output.write line.match(/^\s+/)
				output.puts "\# #{annotations.join(", ")}"
			end
		end
		
		def print_line_header(output)
			output.puts "Line|".rjust(8) + "Hits|".rjust(8)
		end
		
		def print_line(output, line, line_offset, count)
			prefix = "#{line_offset}|".rjust(8) + "#{count}|".rjust(8)
			
			output.write prefix
			output.write line
			
			# If there was no newline at end of file, we add one:
			unless line.end_with?($/)
				output.puts
			end
		end
		
		# A coverage array gives, for each line, the number of line execution by the interpreter. A nil value means coverage is disabled for this line (lines like else and end).
		def call(wrapper, output = $stdout)
			output.puts '# Coverage Report'
			output.puts
			
			ordered = []
			buffer = StringIO.new
			
			statistics = self.each(wrapper) do |coverage|
				ordered << coverage unless coverage.complete?
			end
			
			statistics.print(output)
			
			if ordered.any?
				output.puts "", "\#\# Least Coverage:", ""
				ordered.sort_by!(&:missing_count).reverse!
				
				ordered.first(5).each do |coverage|
					path = wrapper.relative_path(coverage.path)
					
					output.puts "- `#{path}`: #{coverage.missing_count} lines not executed!"
				end
			end
			
			output.print(buffer.string)
		end
	end
end
