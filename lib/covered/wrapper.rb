# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2018-2023, by Samuel Williams.

module Covered
	# The base coverage output interface.
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
		
		# Whether the given path should be accepted.
		# @parameter path [String] The source path.
		# @returns [Boolean] Whether the path should be included.
		def accept?(path)
			true
		end
		
		# Mark coverage for the given path and line number.
		# @parameter path [String] The source path.
		# @parameter lineno [Integer] The starting line number.
		# @parameter value [Integer | Array(Integer)] The execution count or counts to add.
		def mark(path, lineno, value)
		end
		
		# Add a coverage object.
		# @parameter coverage [Covered::Coverage] The coverage object to add.
		def add(coverage)
		end
		
		# Enumerate the coverage data.
		# @yields {|coverage| ...}
		# 	@parameter coverage [Coverage] The coverage data, including the source file and execution counts.
		def each
		end
		
		# Convert a path to a relative path.
		# @parameter path [String] The source path.
		# @returns [String] The relative path.
		def relative_path(path)
			path
		end
		
		# Expand a path relative to this output.
		# @parameter path [String] The path to expand.
		# @returns [String] The expanded path.
		def expand_path(path)
			path
		end
	end
	
	# Wraps another coverage output.
	class Wrapper < Base
		# Initialize the wrapper with the given output.
		# @parameter output [Covered::Base] The output to wrap.
		def initialize(output = Base.new)
			@output = output
		end
		
		# @attribute [Covered::Base] The wrapped output.
		attr :output
		
		# Start tracking coverage on the wrapped output.
		def start
			@output.start
		end
		
		# Clear coverage on the wrapped output.
		def clear
			@output.clear
		end
		
		# Finish tracking coverage on the wrapped output.
		def finish
			@output.finish
		end
		
		# Whether the wrapped output accepts the given path.
		# @parameter path [String] The source path.
		# @returns [Boolean] Whether the wrapped output accepts the path.
		def accept?(path)
			@output.accept?(path)
		end
		
		# Mark coverage on the wrapped output.
		# @parameter path [String] The source path.
		# @parameter lineno [Integer] The starting line number.
		# @parameter value [Integer | Array(Integer)] The execution count or counts to add.
		def mark(path, lineno, value)
			@output.mark(path, lineno, value)
		end
		
		# Add coverage to the wrapped output.
		# @parameter coverage [Covered::Coverage] The coverage object to add.
		def add(coverage)
			@output.add(coverage)
		end
		
		# @yield [Coverage] the path to the file, and the execution counts.
		def each(&block)
			@output.each(&block)
		end
		
		# Convert a path using the wrapped output.
		# @parameter path [String] The source path.
		# @returns [String] The converted path.
		def relative_path(path)
			@output.relative_path(path)
		end
		
		# Expand a path using the wrapped output.
		# @parameter path [String] The path to expand.
		# @returns [String] The expanded path.
		def expand_path(path)
			@output.expand_path(path)
		end
		
		# Convert all coverage data to a hash keyed by path.
		# @returns [Hash(String, Covered::Coverage)] Coverage keyed by path.
		def to_h
			to_enum(:each).collect{|coverage| [coverage.path, coverage]}.to_h
		end
	end
	
	# Filters coverage before forwarding it to another output.
	class Filter < Wrapper
		# Mark coverage if the path is accepted by this filter.
		# @parameter path [String] The source path.
		# @parameter lineno [Integer] The starting line number.
		# @parameter value [Integer | Array(Integer)] The execution count or counts to add.
		def mark(path, lineno, value)
			@output.mark(path, lineno, value) if accept?(path)
		end
		
		# @yield [Coverage] the path to the file, and the execution counts.
		def each(&block)
			@output.each do |coverage|
				yield coverage if accept?(coverage.path)
			end
		end
		
		# Whether the given path is accepted by this filter and its output.
		# @parameter path [String] The source path.
		# @returns [Boolean] Whether this filter and the wrapped output accept the path.
		def accept?(path)
			match?(path) and super
		end
		
		# Whether the given path matches this filter.
		# @parameter path [String] The source path.
		# @returns [Boolean] Whether this filter matches the path.
		def match?(path)
			true
		end
	end
end
