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

require 'set'

module Covered
	class Files < Wrapper
		def initialize(output = nil)
			super(output)
			
			@paths = {}
		end
		
		attr :paths
		
		def empty?
			@paths.empty?
		end
		
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
	
	class Include < Wrapper
		def initialize(output, pattern)
			super(output)
			
			@pattern = pattern
		end
		
		attr :pattern
		
		def glob
			paths = Set.new
			
			Dir.glob(@pattern) do |path|
				unless File.directory?(path)
					paths << File.realpath(path)
				end
			end
			
			return paths
		end
		
		def each(&block)
			paths = glob
			
			super do |path, lines|
				paths.delete(path)
				
				yield path, lines
			end
			
			paths.each do |path|
				yield path, []
			end
		end
	end
	
	class Filter < Wrapper
		def accept?(path)
			true
		end
		
		def mark(path, lineno)
			super if accept?(path)
		end
		
		def each(&block)
			super do |path, counts|
				yield path, counts if accept?(path)
			end
		end
	end
	
	class Skip < Filter
		def initialize(output, pattern)
			super(output)
			
			@pattern = pattern
		end
		
		attr :pattern
		
		def accept? path
			!(@pattern === path)
		end
	end
	
	class Only < Filter
		def initialize(output, pattern)
			super(output)
			
			@pattern = pattern
		end
		
		attr :pattern
		
		def accept?(path)
			@pattern === path
		end
	end
	
	class Root < Filter
		def initialize(output, path)
			super(output)
			
			@path = path
		end
		
		attr :path
		
		def accept?(path)
			path.start_with?(@path)
		end
	end
end
