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

require_relative 'node'
require_relative 'eval'
require_relative 'wrapper'

require 'thread'

module Covered
	class Source < Wrapper
		def initialize(output)
			super
			
			@paths = {}
			@mutex = Mutex.new
		end
		
		def enable
			super
			
			Eval::enable(self)
		end
		
		def disable
			Eval::disable(self)
			
			super
		end
		
		attr :paths
		
		def intercept_eval(string, binding = nil, filename = nil, lineno = 1)
			return unless filename
			
			# TODO replace with Concurrent::Map
			@mutex.synchronize do
				@paths[filename] = string
			end
		end
		
		def expand(node, lines)
			# puts "#{node.first_lineno}: #{node.inspect}"
			
			lines[node.first_lineno] ||= 0 if node.executable?
			
			node.children.each do |child|
				next if child.nil? or child.ignore?
				
				expand(child, lines)
			end
		end
		
		def parse(path)
			if source = @paths[path]
				RubyVM::AST.parse(source)
			elsif File.exist?(path)
				RubyVM::AST.parse_file(path)
			else
				warn "Couldn't parse #{path}, file doesn't exist?"
			end
		end
		
		def each(&block)
			@output.each do |path, lines|
				lines = lines.dup
				
				if top = parse(path)
					expand(top, lines)
				end
				
				yield path, lines
			end
		end
	end
end
