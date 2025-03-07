# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2019-2025, by Samuel Williams.
# Copyright, 2023, by Stephen Ierodiaconou.

require_relative "wrapper"

require "msgpack"
require "time"

module Covered
	class Persist < Wrapper
		DEFAULT_PATH = ".covered.db"
		
		def initialize(output, path = DEFAULT_PATH)
			super(output)
			
			@path = self.expand_path(path)
		end
		
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
		
		def serialize(coverage)
			{
				# We want to use relative paths so that moving the repo won't break everything:
				pid: Process.pid,
				path: relative_path(coverage.path),
				# relative_path: relative_path(coverage.path),
				coverage: coverage,
			}
		end
		
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
		
		def finish
			super
			
			self.save!
		end
		
		def each(&block)
			return to_enum unless block_given?
			
			@output.clear
			self.load!
			
			super
		end
		
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
		
		def make_packer(io)
			return make_factory.packer(io)
		end
		
		def make_unpacker(io)
			return make_factory.unpacker(io)
		end
	end
end
