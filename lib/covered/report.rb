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

require 'rainbow'

require_relative 'ast'

module Covered
	class Report
		def initialize(source)
			@source = source
		end
		
		def expand(node, lines)
			# puts "#{node.first_lineno}: #{node.inspect}"
			
			lines[node.first_lineno] ||= 0 if node.executable?
			
			node.children.each do |child|
				next if child.nil?
				
				expand(child, lines)
			end
		end
		
		# A coverage array gives, for each line, the number of line execution by the interpreter. A nil value means coverage is disabled for this line (lines like else and end).
		def print_summary(output = $stdout)
			@source.each do |path, ast, counts|
				expand(ast, counts)
				
				line_offset = 1
				output.puts Rainbow(path).bold.underline
				
				File.open(path, "r") do |file|
					file.each_line do |line|
						count = counts[line_offset]
						
						output.write("#{line_offset}".rjust(4))
						output.write(" #{count}|".rjust(4))
						
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
				
				covered = counts.compact
				hits = covered.reject(&:zero?)
				percentage = Rational(hits.count, covered.count) * 100
				output.puts "** #{hits.count}/#{covered.count} lines executed; #{percentage.to_f.round(2)}% covered."
			end
		end
	end
end
