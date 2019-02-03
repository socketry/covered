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
	class Base
		def enable
		end
		
		def disable
		end
		
		def accept?(path)
			true
		end
		
		def mark(path, lineno, value)
		end
		
		def each
		end
		
		def relative_path(path)
			path
		end
		
		def expand_path(path)
			path
		end
	end
	
	class Wrapper < Base
		def initialize(output = Base.new)
			@output = output
		end
		
		attr :output
		
		def enable
			@output.enable
		end
		
		def disable
			@output.disable
		end
		
		def accept?(path)
			@output.accept?(path)
		end
		
		def mark(path, lineno, value)
			@output.mark(path, lineno, value)
		end
		
		# @yield [Coverage] the path to the file, and the execution counts.
		def each(&block)
			@output.each(&block)
		end
		
		def relative_path(path)
			@output.relative_path(path)
		end
		
		def expand_path(path)
			@output.expand_path(path)
		end
		
		def to_h
			@output.to_enum(:each).collect{|coverage| [coverage.path, coverage]}.to_h
		end
	end
	
	class Filter < Wrapper
		def mark(path, lineno, value)
			@output.mark(path, lineno, value) if accept?(path)
		end
		
		# @yield [Coverage] the path to the file, and the execution counts.
		def each(&block)
			@output.each do |coverage|
				yield coverage if accept?(coverage.path)
			end
		end
		
		def accept?(path)
			match?(path) and super
		end
		
		def match?(path)
			true
		end
	end
end
