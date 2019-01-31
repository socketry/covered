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

require_relative 'eval'
require_relative 'wrapper'

require 'thread'

require 'parser/current'

module Covered
	# The source map, loads the source file, parses the AST to generate which lines contain executable code.
	class Source < Wrapper
		EXECUTABLE = /(.?CALL|.VAR|.ASGN|DEFN)/.freeze
		
		# Deviate from the standard policy above, because all the files are already loaded, so we skip NODE_FCALL.
		DOGFOOD = /(^V?CALL|.VAR|.ASGN|DEFN)/.freeze
		
		# Ruby trace points don't trigger for argument execution.
		# Constants are loaded when the file loads, so they are less interesting.
		IGNORE = /(ARGS|CDECL)/.freeze
		
		def initialize(output, executable: EXECUTABLE, ignore: IGNORE)
			super(output)
			
			@paths = {}
			@mutex = Mutex.new
			
			@executable = executable
			@ignore = ignore
			
			@annotations = {}
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
			
			@mutex.synchronize do
				@paths[filename] = string
			end
		end
		
		def executable?(node)
			node.type == :send
		end
		
		def ignore?(node)
			node.nil?
		end
		
		def expand(node, coverage, level = 0)
			if node.is_a? Parser::AST::Node
				if ignore?(node)
					coverage.annotate(node.location.line, "ignoring #{node.type}")
				else
					if executable?(node)
						# coverage.annotate(node.first_lineno, "executable #{node.type}")
						coverage.counts[node.location.line] ||= 0
					else
						# coverage.annotate(node.first_lineno, "not executable #{node.type}")
					end
					
					expand(node.children, coverage, level + 1)
				end
			elsif node.is_a? Array
				node.each do |child|
					expand(child, coverage, level)
				end
			else
				return false
			end
		end
		
		def parse(path)
			if source = @paths[path]
				Parser::CurrentRuby.parse(source)
			elsif File.exist?(path)
				Parser::CurrentRuby.parse_file(path)
			else
				warn "Couldn't parse #{path}, file doesn't exist?"
			end
		end
		
		def each(&block)
			@output.each do |coverage|
				# This is a little bit inefficient, perhaps add a cache layer?
				if top = parse(coverage.path)
					self.expand(top, coverage)
				end
				
				yield coverage.freeze
			end
		end
	end
end
