# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2019-2025, by Samuel Williams.
# Copyright, 2023, by Stephen Ierodiaconou.

require_relative "wrapper"

require "msgpack"
require "time"

module Covered
	# Persists coverage records to a MessagePack database.
	class Persist < Wrapper
		DEFAULT_PATH = ".covered.db"
		
		# Initialize persistence for the given output and database path.
		# @parameter output [Covered::Base] The output to wrap.
		# @parameter path [String] The coverage database path.
		def initialize(output, path = DEFAULT_PATH)
			super(output)
			
			@path = self.expand_path(path)
		end
		
		# Apply a persisted record to the output.
		# Records with stale source modification times are ignored unless `ignore_mtime` is true.
		# @parameter record [Hash] The persisted coverage record.
		# @parameter ignore_mtime [Boolean] Whether to apply records even if their source appears stale.
		# @returns [Boolean] Whether the record was applied.
		def apply(record, ignore_mtime: false)
			if coverage = record[:coverage]
				if path = record[:path]
					path = self.expand_path(path)
					coverage.path = path
				end
				
				if ignore_mtime || coverage.fresh?
					add(coverage)
					return true
				end
			end
			
			return false
		end
		
		# Convert coverage into a database record.
		# @parameter coverage [Covered::Coverage] The coverage object to serialize.
		# @returns [Hash] A MessagePack-compatible record.
		def serialize(coverage)
			{
				# We want to use relative paths so that moving the repo won't break everything:
				pid: Process.pid,
				path: relative_path(coverage.path),
				# relative_path: relative_path(coverage.path),
				coverage: coverage,
			}
		end
		
		# Load persisted coverage records into the output.
		# @parameter options [Hash] Options forwarded to {apply}.
		# @raises [LoadError] If the database exists but cannot be decoded.
		def load!(**options)
			return unless File.exist?(@path)
			
			# Load existing coverage information and mark all files:
			File.open(@path, "rb") do |file|
				file.flock(File::LOCK_SH)
				
				make_unpacker(file).each do |record|
					# pp load: record
					self.apply(record, **options)
				end
			end
		rescue
			raise LoadError, "Failed to load coverage from #{@path}, maybe old format or corrupt!"
		end
		
		# Save all output coverage records to the database.
		def save!
			# Dump all coverage:
			File.open(@path, "ab") do |file|
				file.flock(File::LOCK_EX)
				
				packer = make_packer(file)
				
				@output.each do |coverage|
					# pp save: coverage
					packer.write(serialize(coverage))
				end
				
				packer.flush
			end
		end
		
		# Finish the wrapped output and save the coverage database.
		def finish
			super
			
			self.save!
		end
		
		# Reload persisted coverage and enumerate the wrapped output.
		# @yields {|coverage| ...} Each coverage object from the reloaded output.
		# 	@parameter coverage [Covered::Coverage] The current coverage object.
		# @returns [Enumerator | Nil] An enumerator without a block.
		def each(&block)
			return to_enum unless block_given?
			
			@output.clear
			self.load!
			
			super
		end
		
		# Build the MessagePack factory used for coverage records.
		# @returns [MessagePack::Factory] The configured MessagePack factory.
		def make_factory
			factory = MessagePack::Factory.new
			
			factory.register_type(0x00, Symbol)
			
			factory.register_type(0x01, Time,
				packer: MessagePack::Time::Packer,
				unpacker: MessagePack::Time::Unpacker
			)
			
			factory.register_type(0x20, Source,
				recursive: true,
				packer: :serialize,
				unpacker: :deserialize,
			)
			
			factory.register_type(0x21, Coverage,
				recursive: true,
				packer: :serialize,
				unpacker: :deserialize,
			)
			
			return factory
		end
		
		# Build a MessagePack packer for the given IO.
		# @parameter io [IO] The IO to write packed records to.
		# @returns [MessagePack::Packer] A packer configured for coverage records.
		def make_packer(io)
			return make_factory.packer(io)
		end
		
		# Build a MessagePack unpacker for the given IO.
		# @parameter io [IO] The IO to read packed records from.
		# @returns [MessagePack::Unpacker] An unpacker configured for coverage records.
		def make_unpacker(io)
			return make_factory.unpacker(io)
		end
	end
end
