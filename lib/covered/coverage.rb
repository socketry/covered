# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2018-2025, by Samuel Williams.

require_relative "source"

module Covered
	# Computes common coverage ratios from executed and executable line counts.
	module Ratio
		# The fraction of executable lines that were executed.
		# @returns [Rational | Float] The executed-to-executable line ratio, or `1.0` when there are no executable lines.
		def ratio
			return 1.0 if executable_count.zero?
			
			Rational(executed_count, executable_count)
		end
		
		# Whether all executable lines were executed.
		# @returns [Boolean] Whether `executed_count` equals `executable_count`.
		def complete?
			executed_count == executable_count
		end
		
		# The coverage ratio as a percentage.
		# @returns [Numeric] The coverage ratio multiplied by `100`.
		def percentage
			ratio * 100
		end
	end
	
	# Stores line execution counts and source metadata for a single file.
	class Coverage
		include Ratio
		
		# Build coverage for the given source path.
		# @parameter path [String] The source path.
		# @parameter options [Hash] Options forwarded to {Covered::Source.for}.
		# @returns [Covered::Coverage] The coverage object for the source path.
		def self.for(path, **options)
			self.new(Source.for(path, **options))
		end
		
		# Initialize coverage with the given source, line counts and annotations.
		# @parameter source [Covered::Source] The covered source metadata.
		# @parameter counts [Array(Integer | Nil)] Line execution counts indexed by line number.
		# @parameter annotations [Hash(Integer, Array(String))] Line annotations indexed by line number.
		def initialize(source, counts = [], annotations = {})
			@source = source
			@counts = counts
			@annotations = annotations
		end
		
		# Initialize a copy of this coverage object.
		# @parameter other [Covered::Coverage] The coverage object to copy.
		def initialize_copy(other)
			super
			
			@source = other.source.dup
			@counts = other.counts.dup
			@annotations = other.annotations.transform_values(&:dup)
		end
		
		# @attribute [Covered::Source] The covered source metadata.
		attr_accessor :source
		
		# @attribute [Array(Integer | Nil)] Line execution counts indexed by line number.
		attr :counts
		
		# @attribute [Hash(Integer, Array(String))] Line annotations indexed by line number.
		attr :annotations
		
		# The total number of executions across all tracked lines.
		# @returns [Integer] The sum of all non-`nil` execution counts.
		def total
			counts.sum{|count| count || 0}
		end
		
		# Create an empty coverage with the same source.
		# @returns [Covered::Coverage] Coverage with the same source and `nil` counts.
		def empty
			self.class.new(@source, [nil] * @counts.size)
		end
		
		# Add an annotation to the given line number.
		# @parameter line_number [Integer] The line number to annotate.
		# @parameter annotation [String] The annotation text.
		def annotate(line_number, annotation)
			@annotations[line_number] ||= []
			@annotations[line_number] << annotation
		end
		
		# Add the given execution count to one or more line numbers.
		# @parameter line_number [Integer] The first line number to mark.
		# @parameter value [Integer | Array(Integer)] The execution count or counts to add.
		def mark(line_number, value = 1)
			Array(value).each_with_index do |value, index|
				offset = line_number + index
				next if offset < 1
				
				if @counts[offset]
					@counts[offset] += value
				else
					@counts[offset] = value
				end
			end
		end
		
		# Merge another coverage object into this coverage object.
		# @parameter other [Covered::Coverage] The coverage object to merge.
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
		# @returns [Covered::Coverage] A coverage object containing counts for the selected lines.
		def for_lines(line_numbers)
			counts = [nil] * @counts.size
			line_numbers.each do |line_number|
				counts[line_number] = @counts[line_number]
			end
			
			self.class.new(@source, counts, @annotations)
		end
		
		# The covered source path.
		# @returns [String] The covered source path.
		def path
			@source.path
		end
		
		# Assign the covered source path.
		# @parameter value [String] The new covered source path.
		def path= value
			@source.path = value
		end
		
		# Whether the source file has not changed since this coverage was recorded.
		# @returns [Boolean] Whether the source exists and its modification time is not newer than the recorded time.
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
		
		# Read the covered source.
		# @yields {|file| ...} If a block is given, yields an open source file.
		# 	@parameter file [File] The open source file.
		# @returns [String | Object] The source contents without a block, or the block result with a block.
		def read(&block)
			@source.read(&block)
		end
		
		# Freeze this coverage and its mutable collections.
		# @returns [Covered::Coverage] This frozen coverage object.
		def freeze
			return self if frozen?
			
			@counts.freeze
			@annotations.freeze
			
			super
		end
		
		# The raw coverage counts array.
		# @returns [Array(Integer | Nil)] The raw coverage counts.
		def to_a
			@counts
		end
		
		# Whether this coverage has no executions.
		# @returns [Boolean] Whether the total execution count is zero.
		def zero?
			total.zero?
		end
		
		# The raw coverage count for the given line number.
		# @parameter line_number [Integer] The line number to query.
		# @returns [Integer | Nil] The execution count for the line.
		def [] line_number
			@counts[line_number]
		end
		
		# Counts for lines that are executable.
		# @returns [Array(Integer)] Execution counts for executable lines.
		def executable_lines
			@counts.compact
		end
		
		# The number of executable lines.
		# @returns [Integer] The number of executable lines.
		def executable_count
			executable_lines.count
		end
		
		# Counts for executable lines that were executed.
		# @returns [Array(Integer)] Non-zero execution counts for executable lines.
		def executed_lines
			executable_lines.reject(&:zero?)
		end
		
		# The number of executable lines that were executed.
		# @returns [Integer] The number of executed lines.
		def executed_count
			executed_lines.count
		end
		
		# The number of executable lines that were not executed.
		# @returns [Integer] The number of missing executable lines.
		def missing_count
			executable_count - executed_count
		end
		
		# Print a human-readable coverage summary.
		# @parameter output [IO] The output stream.
		def print(output)
			output.puts "** #{executed_count}/#{executable_count} lines executed; #{percentage.to_f.round(2)}% covered."
		end
		
		# A human-readable representation of this coverage object.
		# @returns [String] A summary including the source path and percentage.
		def to_s
			"\#<#{self.class} path=#{self.path} #{self.percentage.to_f.round(2)}% covered>"
		end
		
		# A JSON-compatible representation of this coverage object.
		# @returns [Hash] The coverage counts and summary statistics.
		def as_json
			{
				counts: counts,
				executable_count: executable_count,
				executed_count: executed_count,
				percentage: percentage.to_f.round(2),
			}
		end
		
		# Serialize this coverage object with the given packer.
		# @parameter packer [Object] The MessagePack-compatible packer.
		def serialize(packer)
			packer.write(@source)
			packer.write(@counts)
			packer.write(@annotations)
		end
		
		# Deserialize a coverage object from the given unpacker.
		# @parameter unpacker [Object] The MessagePack-compatible unpacker.
		# @returns [Covered::Coverage] The deserialized coverage object.
		def self.deserialize(unpacker)
			source = unpacker.read
			counts = unpacker.read
			annotations = unpacker.read
			
			self.new(source, counts, annotations)
		end
	end
end
