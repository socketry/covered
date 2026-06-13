# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2018-2025, by Samuel Williams.

require_relative "coverage"
require_relative "wrapper"

require "set"

module Covered
	# Collects coverage information keyed by source path.
	class Files < Base
		# Initialize an empty coverage collection.
		def initialize(*)
			super
			
			@paths = {}
		end
		
		# @attribute [Hash(String, Covered::Coverage)] Coverage indexed by expanded source path.
		attr_accessor :paths
		
		# Get or create coverage for the given path.
		# @parameter path [String] The source path.
		# @returns [Covered::Coverage] The coverage object for the path.
		def [](path)
			@paths[path] ||= Coverage.for(path)
		end
		
		# Whether there are no tracked paths.
		# @returns [Boolean] Whether no coverage paths are tracked.
		def empty?
			@paths.empty?
		end
		
		# Mark a line in the given path as executed.
		# @parameter path [String] The source path.
		# @parameter line_number [Integer] The line number to mark.
		# @parameter value [Integer | Array(Integer)] The execution count or counts to add.
		def mark(path, line_number, value)
			self[path].mark(line_number, value)
		end
		
		# Add an annotation to a line in the given path.
		# @parameter path [String] The source path.
		# @parameter line_number [Integer] The line number to annotate.
		# @parameter value [String] The annotation text.
		def annotate(path, line_number, value)
			self[path].annotate(line_number, value)
		end
		
		# Merge coverage for the given path into this collection.
		# @parameter coverage [Covered::Coverage] The coverage object to merge.
		def add(coverage)
			self[coverage.path].merge!(coverage)
		end
		
		# Enumerate tracked coverage objects.
		# @yields {|coverage| ...} Each tracked coverage object.
		# 	@parameter coverage [Covered::Coverage] The current coverage object.
		# @returns [Enumerator | Nil] An enumerator without a block.
		def each
			return to_enum unless block_given?
			
			@paths.each_value do |coverage|
				yield coverage
			end
		end
		
		# Remove all tracked coverage data.
		# @returns [Hash] The cleared path map.
		def clear
			@paths.clear
		end
	end
	
	# Includes coverage for files matching a glob pattern.
	class Include < Wrapper
		# Initialize an include filter for the given glob pattern.
		# @parameter output [Covered::Base] The output to wrap.
		# @parameter pattern [String] The glob pattern to include.
		# @parameter base [String] The base path used to expand the glob.
		def initialize(output, pattern, base = "")
			super(output)
			
			@pattern = pattern
			@base = base
		end
		
		# @attribute [String] The glob pattern to include.
		attr :pattern
		
		# Resolve the include pattern to real file paths.
		# @returns [Set(String)] The real paths matched by the include pattern.
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
		
		# Enumerate existing coverage and synthesize empty coverage for unmatched included files.
		# @yields {|coverage| ...} Each existing or synthesized coverage object.
		# 	@parameter coverage [Covered::Coverage] The current coverage object.
		def each(&block)
			paths = glob
			
			super do |coverage|
				paths.delete(coverage.path)
				
				yield coverage
			end
			
			paths.each do |path|
				yield Coverage.for(path)
			end
		end
	end
	
	# Excludes coverage for paths matching a pattern.
	class Skip < Filter
		# Initialize a skip filter for the given pattern.
		# @parameter output [Covered::Base] The output to wrap.
		# @parameter pattern [Regexp] The pattern to exclude.
		def initialize(output, pattern)
			super(output)
			
			@pattern = pattern
		end
		
		# @attribute [Regexp] The pattern to exclude.
		attr :pattern
		
		if Regexp.instance_methods.include? :match?
			# This is better as it doesn't allocate a MatchData instance which is essentially useless:
			def match? path
				!@pattern.match?(path)
			end
		else
			def match? path
				!(@pattern =~ path)
			end
		end
	end
	
	# Only includes coverage for paths matching a pattern.
	class Only < Filter
		# Initialize an only filter for the given pattern.
		# @parameter output [Covered::Base] The output to wrap.
		# @parameter pattern [Object] The pattern matched with `===`.
		def initialize(output, pattern)
			super(output)
			
			@pattern = pattern
		end
		
		# @attribute [Object] The pattern matched with `===`.
		attr :pattern
		
		# Whether the given path matches the only pattern.
		# @parameter path [String] The source path.
		# @returns [Boolean] Whether the path matches the pattern.
		def match?(path)
			@pattern === path
		end
	end
	
	# Restricts coverage to a project root and converts paths relative to it.
	class Root < Filter
		# Initialize a root filter for the given path.
		# @parameter output [Covered::Base] The output to wrap.
		# @parameter path [String] The root path.
		def initialize(output, path)
			super(output)
			
			@path = path
		end
		
		# @attribute [String] The root path.
		attr :path
		
		# Expand a path relative to this root.
		# @parameter path [String] The path to expand.
		# @returns [String] The expanded path.
		def expand_path(path)
			File.expand_path(super, @path)
		end
		
		# Convert a path under this root to a relative path.
		# @parameter path [String] The path to relativize.
		# @returns [String] The relative path when under this root, otherwise the wrapped output result.
		def relative_path(path)
			if path.start_with?(@path)
				path.slice(@path.size+1, path.size)
			else
				super
			end
		end
		
		# Whether the given path is under this root.
		# @parameter path [String] The source path.
		# @returns [Boolean] Whether the path starts with this root.
		def match?(path)
			path.start_with?(@path)
		end
	end
end
