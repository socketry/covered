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

module Covered
	class Statistics
		def initialize
			@count = 0
			@executable_count = 0
			@executed_count = 0
		end
		
		# Total number of files added.
		attr :count
		
		# The number of lines which could have been executed.
		attr :executable_count
		
		# The number of lines that were executed.
		attr :executed_count
		
		def << coverage
			@count += 1
			@executable_count += coverage.executable_count
			@executed_count += coverage.executed_count
		end
		
		def percentage
			return nil if executable_count.zero?
			
			Rational(executed_count, executable_count) * 100
		end
		
		def complete?
			executed_count == executable_count
		end
		
		def print_summary(output)
			output.puts "* #{count} files checked; #{executed_count}/#{executable_count} lines executed; #{percentage.to_f.round(2)}% covered."
		end
	end
	
	class Coverage
		def initialize(path, lines)
			@path = path
			@lines = lines
			
			@executable_lines = nil
			@executed_lines = nil
		end
		
		attr :lines
		
		def executable_lines
			@executable_lines ||= @lines.compact
		end
		
		def executable_count
			executable_lines.count
		end
		
		def executed_lines
			@executed_lines ||= executable_lines.reject(&:zero?)
		end
		
		def executed_count
			executed_lines.count
		end
		
		def complete?
			executed_count == executable_count
		end
		
		def percentage
			return nil if executable_count.zero?
			
			Rational(executed_count, executable_count) * 100
		end
		
		def print_summary(output)
			output.puts "** #{executed_count}/#{executable_count} lines executed; #{percentage.to_f.round(2)}% covered."
		end
	end
end
