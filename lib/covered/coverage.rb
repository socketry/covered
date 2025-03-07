# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2018-2025, by Samuel Williams.

require_relative "source"

module Covered
	module Ratio
		def ratio
			return 1.0 if executable_count.zero?
			
			Rational(executed_count, executable_count)
		end
		
		def complete?
			executed_count == executable_count
		end
		
		def percentage
			ratio * 100
		end
	end
	
	class Coverage
		include Ratio
		
		def self.for(path, **options)
			self.new(Source.for(path, **options))
		end
		
		def initialize(source, counts = [], annotations = {})
			@source = source
			@counts = counts
			@annotations = annotations
		end
		
		attr_accessor :source
		attr :counts
		attr :annotations
		
		def total
			counts.sum{|count| count || 0}
		end
		
		# Create an empty coverage with the same source.
		def empty
			self.class.new(@source, [nil] * @counts.size)
		end
		
		def annotate(line_number, annotation)
			@annotations[line_number] ||= []
			@annotations[line_number] << annotation
		end
		
		def mark(line_number, value = 1)
			# As currently implemented, @counts is base-zero rather than base-one.
			# Line numbers generally start at line 1, so the first line, line 1, is at index 1. This means that index[0] is usually nil.
			Array(value).each_with_index do |value, index|
				offset = line_number + index
				if @counts[offset]
					@counts[offset] += value
				else
					@counts[offset] = value
				end
			end
		end
		
		def merge!(other)
			# If the counts are non-zero and don't match, that can indicate a problem.
			
			other.counts.each_with_index do |count, index|
				if count
					@counts[index] ||= 0
					@counts[index] += count
				end
			end
			
			@annotations.merge!(other.annotations) do |line_number, a, b|
				Array(a) + Array(b)
			end
		end
		
		# Construct a new coverage object for the given line numbers. Only the given line numbers will be considered for the purposes of computing coverage.
		# @parameter line_numbers [Array(Integer)] The line numbers to include in the new coverage object.
		def for_lines(line_numbers)
			counts = [nil] * @counts.size
			line_numbers.each do |line_number|
				counts[line_number] = @counts[line_number]
			end
			
			self.class.new(@source, counts, @annotations)
		end
		
		def path
			@source.path
		end
		
		def path= value
			@source.path = value
		end
		
		def fresh?
			if @source.modified_time.nil?
				# We don't know when the file was last modified, so we assume it is stale:
				return false
			end
			
			unless File.exist?(@source.path)
				# The file no longer exists, so we assume it is stale:
				return false
			end
			
			if @source.modified_time >= File.mtime(@source.path)
				# The file has not been modified since we last processed it, so we assume it is fresh:
				return true
			end
			
			return false
		end
		
		def read(&block)
			@source.read(&block)
		end
		
		def freeze
			return self if frozen?
			
			@counts.freeze
			@annotations.freeze
			
			super
		end
		
		def to_a
			@counts
		end
		
		def zero?
			total.zero?
		end
		
		def [] line_number
			@counts[line_number]
		end
		
		def executable_lines
			@counts.compact
		end
		
		def executable_count
			executable_lines.count
		end
		
		def executed_lines
			executable_lines.reject(&:zero?)
		end
		
		def executed_count
			executed_lines.count
		end
		
		def missing_count
			executable_count - executed_count
		end
		
		def print(output)
			output.puts "** #{executed_count}/#{executable_count} lines executed; #{percentage.to_f.round(2)}% covered."
		end
		
		def to_s
			"\#<#{self.class} path=#{self.path} #{self.percentage.to_f.round(2)}% covered>"
		end
		
		def as_json
			{
				counts: counts,
				executable_count: executable_count,
				executed_count: executed_count,
				percentage: percentage.to_f.round(2),
			}
		end
		
		def serialize(packer)
			packer.write(@source)
			packer.write(@counts)
			packer.write(@annotations)
		end
		
		def self.deserialize(unpacker)
			source = unpacker.read
			counts = unpacker.read
			annotations = unpacker.read
			
			self.new(source, counts, annotations)
		end
	end
end
