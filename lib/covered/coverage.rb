# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2018-2023, by Samuel Williams.

require_relative 'source'

module Covered
	module Ratio
		def ratio
			return 0 if executable_count.zero?
			
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
		
		def initialize(source, counts = [], annotations = {}, total = nil)
			@source = source
			@counts = counts
			@annotations = annotations
			
			@total = total || counts.sum{|count| count || 0}
			
			# Memoized metrics:
			@executable_lines = nil
			@executed_lines = nil
		end
		
		# Construct a new coverage object for the given line numbers. Only the given line numbers will be considered for the purposes of computing coverage.
		# @parameter line_numbers [Array(Integer)] The line numbers to include in the new coverage object.
		def for_lines(line_numbers)
			self.class.new(@source, @counts.values_at(*line_numbers), @annotations)
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
		
		attr_accessor :source
		
		attr :counts
		attr :total
		
		attr :annotations
		
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
			@total.zero?
		end
		
		def [] lineno
			@counts[lineno]
		end
		
		def executable_lines
			@executable_lines ||= @counts.compact
		end
		
		def executable_count
			executable_lines.count
		end
		
		def executed_lines
			@executed_lines ||= executable_lines.reject(&:zero?)
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
			"\#<#{self.class} path=#{self.path} #{self.summary.percentage.to_f.round(2)}% covered>"
		end
		
		def serialize(packer)
			packer.write(@source)
			packer.write(@counts)
			packer.write(@annotations)
			packer.write(@total)
		end
		
		def self.deserialize(unpacker)
			source = unpacker.read
			counts = unpacker.read
			annotations = unpacker.read
			total = unpacker.read
			
			self.new(source, counts, annotations, total)
		end
	end
end
