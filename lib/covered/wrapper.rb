# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2018-2023, by Samuel Williams.

module Covered
	class Base
		# Start tracking coverage.
		def start
		end
		
		# Discard any coverage data and restart tracking.
		def clear
		end
		
		# Stop tracking coverage.
		def finish
		end
		
		def accept?(path)
			true
		end
		
		def mark(path, lineno, value)
		end
		
		def add(coverage)
		end
		
		# Enumerate the coverage data.
		# @yields {|coverage| ...}
		# 	@parameter coverage [Coverage] The coverage data, including the source file and execution counts.
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
		
		def start
			@output.start
		end
		
		def clear
			@output.clear
		end
		
		def finish
			@output.finish
		end
		
		def accept?(path)
			@output.accept?(path)
		end
		
		def mark(path, lineno, value)
			@output.mark(path, lineno, value)
		end
		
		def add(coverage)
			@output.add(coverage)
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
			to_enum(:each).collect{|coverage| [coverage.path, coverage]}.to_h
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
