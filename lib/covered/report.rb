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
		def initialize(files)
			@files = files
		end
		
		def expand(node, lines)
			# puts "#{node.inspect} #{node.first_lineno} #{node.last_lineno}"
			
			lines[node.first_lineno] ||= 0 if node.executable?
			
			node.children.each do |child|
				next if child.nil?
				
				expand(child, lines)
			end
		end
		
		# A coverage array gives, for each line, the number of line execution by the interpreter. A nil value means coverage is disabled for this line (lines like else and end).
		def print_summary(output = $stdout)
			output.puts "* Summary "
			@files.each do |path, counts|
				ast = RubyVM::AST::parse_file(path)
				expand(ast, counts)
				
				line_offset = 1
				output.puts "** #{path}"
				
				File.open(path, "r") do |file|
					file.each_line do |line, index|
						count = counts[line_offset]
						
						if count == nil
							output.write line
						elsif count == 0
							output.write Rainbow(line).red
						else
							output.write Rainbow(line).green
						end
						
						line_offset += 1
					end
				end
				
				covered = counts.compact
				output.puts "** Coverage: #{covered.reject(&:zero?).count}/#{covered.count}"
			end
		end
	end
end
