# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2018-2025, by Samuel Williams.

require_relative "coverage"
require_relative "wrapper"

require "set"

module Covered
	class Files < Base
		def initialize(*)
			super
			
			@paths = {}
		end
		
		attr_accessor :paths
		
		def [](path)
			@paths[path] ||= Coverage.for(path)
		end
		
		def empty?
			@paths.empty?
		end
		
		def mark(path, line_number, value)
			self[path].mark(line_number, value)
		end
		
		def annotate(path, line_number, value)
			self[path].annotate(line_number, value)
		end
		
		def add(coverage)
			self[coverage.path].merge!(coverage)
		end
		
		def each
			return to_enum unless block_given?
			
			@paths.each_value do |coverage|
				yield coverage
			end
		end
		
		def clear
			@paths.clear
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
				yield Coverage.for(path)
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
			File.expand_path(super, @path)
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
