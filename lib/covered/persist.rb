# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2019-2022, by Samuel Williams.

require_relative 'wrapper'

require 'msgpack'
require 'time'
require 'set'

module Covered
	class Persist < Wrapper
		DEFAULT_PATH = ".covered.db"
		
		def initialize(output, path = DEFAULT_PATH)
			super(output)
			
			@path = path
			@touched = Set.new
		end
		
		def apply(record, ignore_mtime: false)
			# The file must still exist:
			return unless path = expand_path(record[:path])
			
			unless File.exist?(path)
				# Ignore this coverage, the file no longer exists.
				return
			end
			
			# If the file has been modified since... we can't use the coverage.
			return unless mtime = record[:mtime]
			
			unless ignore_mtime
				if File.mtime(path).to_f > record[:mtime]
					# Ignore this coverage, the file has been modified since it was recorded.
					return
				end
			end
			
			if source = record[:source]
				@output.add(source)
			end
			
			record[:counts].each_with_index do |count, index|
				@output.mark(path, index, count) if count
			end
		end
		
		def serialize(coverage)
			{
				# We want to use relative paths so that moving the repo won't break everything:
				path: relative_path(coverage.path),
				mtime: File.mtime(coverage.path).to_f,
				counts: coverage.counts,
				source: coverage.source,
			}
		end
		
		def load!(**options)
			return unless File.exist?(@path)
			
			# Load existing coverage information and mark all files:
			File.open(@path, "rb") do |file|
				file.flock(File::LOCK_SH)
				
				make_unpacker(file).each do |record|
					self.apply(record, **options)
				end
			end
		rescue => error
			raise LoadError, "Failed to load coverage from #{@path}, maybe old format or corrupt!"
		end
		
		def save!
			# Dump all coverage:
			File.open(@path, "wb") do |file|
				file.flock(File::LOCK_EX)
				
				packer = make_packer(file)
				
				self.each do |coverage|
					packer.write(serialize(coverage))
				end
				
				packer.flush
			end
		end
		
		def mark(file, line, count)
			@touched << file
			
			super
		end
		
		def enable
			super
			
			load!
		end
		
		def flush
			load!
			
			super
		end
		
		def disable
			super
			
			# @touched.each do |path|
			# 	if @output.accept?(path)
			# 		puts "Updated #{path} coverage."
			# 	end
			# end
			
			save!
		end
		
		# def each
		# 	super do |coverage|
		# 		if @touched.include?(coverage.path)
		# 			yield coverage
		# 		end
		# 	end
		# end
		
		def make_packer(io)
			packer = MessagePack::Packer.new(io)
			packer.register_type(0x00, Symbol, :to_msgpack_ext)
			packer.register_type(0x01, Time) {|object| object.to_s}
			packer.register_type(0x0F, Coverage::Source) do |object|
				object.to_a.to_msgpack
			end
			
			return packer
		end
		
		def make_unpacker(io)
			unpacker = MessagePack::Unpacker.new(io)
			unpacker.register_type(0x00, Symbol, :from_msgpack_ext)
			unpacker.register_type(0x01, Time, :parse)
			unpacker.register_type(0x0F) do |data|
				Coverage::Source.new(*MessagePack.unpack(data))
			end
			
			return unpacker
		end
	end
end
