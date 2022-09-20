# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2018-2022, by Samuel Williams.

module Covered
	class Base
		def enable
		end
		
		def disable
		end
		
		def flush
		end
		
		def accept?(path)
			true
		end
		
		def mark(path, lineno, value)
		end
		
		def add(source)
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
		
		def flush
			@output.flush
		end
		
		def accept?(path)
			@output.accept?(path)
		end
		
		def mark(path, lineno, value)
			@output.mark(path, lineno, value)
		end
		
		def add(source)
			@output.add(source)
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
