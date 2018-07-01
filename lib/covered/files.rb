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
	class Files
		def initialize
			@paths = {}
		end
		
		attr :paths
		
		def mark(path, lineno)
			file = @paths[path] ||= []
			if file[lineno]
				file[lineno] += 1
			else
				file[lineno] = 1
			end
		end
		
		def each(&block)
			@paths.each(&block)
		end
	end
	
	class Ignore
		def initialize(pattern, output)
			@pattern = pattern
			@output = output
		end
		
		def mark(path, lineno)
			@output.mark(path, lineno) unless @pattern.match? path
		end
	end
	
	class Group
		def initialize(patterns, output)
			@patterns = patterns
			@output = output
		end
		
		def mark(path, lineno)
			@patterns.each do |pattern, output|
				return output.mark(path, lineno) if pattern.match? path
			end
			
			@output.mark(path, lineno) if @output
		end
	end
	
	class Relative
		def initialize(root, output)
			@root = root
			@output = output
		end
		
		def mark(path, lineno)
			if path.start_with? @root
				@output.mark(path, lineno)
			end
		end
	end
end
