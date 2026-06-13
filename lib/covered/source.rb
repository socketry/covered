# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2018-2023, by Samuel Williams.

module Covered
	# Source code metadata for a covered file or generated template.
	class Source
		# Build source metadata for the given path.
		# Records the current file modification time when the path exists.
		# @parameter path [String] The source path.
		# @parameter options [Hash] Options forwarded to {initialize}.
		# @returns [Covered::Source] The source metadata.
		def self.for(path, **options)
			if File.exist?(path)
				# options[:code] ||= File.read(path)
				options[:modified_time] ||= File.mtime(path)
			end
			
			self.new(path, **options)
		end
		
		# Initialize source metadata.
		# @parameter path [String] The source path.
		# @parameter code [String | Nil] Optional generated source code.
		# @parameter line_offset [Integer] The starting line offset.
		# @parameter modified_time [Time | Nil] The source modification time.
		def initialize(path, code: nil, line_offset: 1, modified_time: nil)
			@path = path
			@code = code
			@line_offset = line_offset
			@modified_time = modified_time
		end
		
		# @attribute [String] The source path.
		attr_accessor :path
		
		# @attribute [String | Nil] Optional generated source code.
		attr :code
		
		# @attribute [Integer] The starting line offset for generated source code.
		attr :line_offset
		
		# @attribute [Time | Nil] The recorded source modification time.
		attr :modified_time
		
		# A human-readable representation of this source.
		# @returns [String] A summary containing the source path.
		def to_s
			"\#<#{self.class} path=#{path}>"
		end
		
		# Read the source code from disk.
		# @yields {|file| ...} If a block is given, yields an open source file.
		# 	@parameter file [File] The open source file.
		# @returns [String | Object] The source contents without a block, or the block result with a block.
		def read(&block)
			if block_given?
				File.open(self.path, "r", &block)
			else
				File.read(self.path)
			end
		end
		
		# The actual code which is being covered. If a template generates the source, this is the generated code, while the path refers to the template itself.
		# @returns [String] The generated code when present, otherwise the file contents.
		def code!
			self.code || self.read
		end
		
		# Whether generated source code is present.
		# @returns [Boolean] Whether this source has generated code.
		def code?
			!!self.code
		end
		
		# Serialize this source with the given packer.
		# @parameter packer [Object] The MessagePack-compatible packer.
		def serialize(packer)
			packer.write(self.path)
			packer.write(self.code)
			packer.write(self.line_offset)
			packer.write(self.modified_time)
		end
		
		# Deserialize a source from the given unpacker.
		# @parameter unpacker [Object] The MessagePack-compatible unpacker.
		# @returns [Covered::Source] The deserialized source metadata.
		def self.deserialize(unpacker)
			path = unpacker.read
			code = unpacker.read
			line_offset = unpacker.read
			modified_time = unpacker.read
			
			self.new(path, code: code, line_offset: line_offset, modified_time: modified_time)
		end
	end
end
