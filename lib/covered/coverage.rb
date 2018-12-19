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
	module Ratio
		def ratio
			return 1 if executable_count.zero?
			
			Rational(executed_count, executable_count)
		end
		
		def complete?
			executed_count == executable_count
		end
		
		def percentage
			ratio * 100
		end
	end
	
	class Coverage
		def initialize(path, counts = [])
			@path = path
			@counts = counts
			
			@annotations = {}
			
			@executable_lines = nil
			@executed_lines = nil
		end
		
		attr :path
		attr :counts
		
		attr :annotations
		
		def freeze
			return if frozen?
			
			@counts.freeze
			@annotations.freeze
			
			executable_lines
			executed_lines
			
			super
		end
		
		def [] lineno
			@counts[lineno]
		end
		
		def annotate(lineno, annotation)
			@annotations[lineno] ||= []
			@annotations[lineno] << annotation
		end
		
		def mark(lineno, value = 1)
			if @counts[lineno]
				@counts[lineno] += value
			else
				@counts[lineno] = value
			end
		end
		
		def executable_lines
			@executable_lines ||= @counts.compact
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
		
		include Ratio
		
		def print_summary(output)
			output.puts "** #{executed_count}/#{executable_count} lines executed; #{percentage.to_f.round(2)}% covered."
		end
	end
end
