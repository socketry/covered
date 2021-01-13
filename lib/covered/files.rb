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

require_relative 'coverage'
require_relative 'wrapper'

require 'set'

module Covered
	class Files < Base
		def initialize(*)
			super
			
			@paths = {}
		end
		
		attr :paths
		
		def empty?
			@paths.empty?
		end
		
		def mark(path, lineno, value)
			coverage = (@paths[path] ||= Coverage.new(path))
			
			coverage.mark(lineno, value)
			
			return coverage
		end
		
		def each(&block)
			@paths.each_value(&block)
		end
	end
	
	class Include < Wrapper
		def initialize(output, pattern, base = "")
			super(output)
			
			@pattern = pattern
			@base = base
		end
		
		attr :pattern
		
		def glob
			paths = Set.new
			root = self.expand_path(@base)
			pattern = File.expand_path(@pattern, root)
			
			Dir.glob(pattern) do |path|
				unless File.directory?(path)
					paths << File.realpath(path)
				end
			end
			
			return paths
		end
		
		def each(&block)
			paths = glob
			
			super do |coverage|
				paths.delete(coverage.path)
				
				yield coverage
			end
			
			paths.each do |path|
				yield Coverage.new(path)
			end
		end
	end
	
	class Skip < Filter
		def initialize(output, pattern)
			super(output)
			
			@pattern = pattern
		end
		
		attr :pattern
		
		if Regexp.instance_methods.include? :match?
			# This is better as it doesn't allocate a MatchData instance which is essentially useless.
			def match? path
				!@pattern.match?(path)
			end
		else
			def match? path
				!(@pattern =~ path)
			end
		end
	end
	
	class Only < Filter
		def initialize(output, pattern)
			super(output)
			
			@pattern = pattern
		end
		
		attr :pattern
		
		def match?(path)
			@pattern === path
		end
	end
	
	class Root < Filter
		def initialize(output, path)
			super(output)
			
			@path = path
		end
		
		attr :path
		
		def expand_path(path)
			File.expand_path(super, path)
		end
		
		def relative_path(path)
			if path.start_with?(@path)
				path.slice(@path.size+1, path.size)
			else
				super
			end
		end
		
		def match?(path)
			path.start_with?(@path)
		end
	end
end
