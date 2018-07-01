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
	class Source
		def initialize(files)
			@files = files
			@paths = {}
			
			@mutex = Mutex.new
		end
		
		# [String -> Source]
		attr :paths
		
		def map(string, binding = nil, filename = nil, lineno = 1)
			return unless filename
			
			# TODO replace with Concurrent::Map
			@mutex.synchronize do
				@paths[filename] = string
			end
		end
		
		def mark(path, lineno)
			@files.mark(path, lineno)
		end
		
		def each(&block)
			@files.each do |path, lines|
				if source = @paths[path]
					yield path, RubyVM::AST.parse(source), lines
				else
					yield path, RubyVM::AST.parse_file(path), lines
				end
			end
		end
	end
end
