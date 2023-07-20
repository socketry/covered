# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2018-2023, by Samuel Williams.

module Covered
	class Source
		def self.for(path, **options)
			if File.exist?(path)
				# options[:code] ||= File.read(path)
				options[:modified_time] ||= File.mtime(path)
			end
			
			self.new(path, **options)
		end
		
		def initialize(path, code: nil, line_offset: 1, modified_time: nil)
			@path = path
			@code = code
			@line_offset = line_offset
			@modified_time = modified_time
		end
		
		attr_accessor :path
		attr :code
		attr :line_offset
		attr :modified_time
		
		def to_s
			"\#<#{self.class} path=#{path}>"
		end
		
		def read(&block)
			if block_given?
				File.open(self.path, "r", &block)
			else
				File.read(self.path)
			end
		end
		
		# The actual code which is being covered. If a template generates the source, this is the generated code, while the path refers to the template itself.
		def code!
			self.code || self.read
		end
		
		def code?
			!!self.code
		end
		
		def serialize(packer)
			packer.write(self.path)
			packer.write(self.code)
			packer.write(self.line_offset)
			packer.write(self.modified_time)
		end
		
		def self.deserialize(unpacker)
			path = unpacker.read
			code = unpacker.read
			line_offset = unpacker.read
			modified_time = unpacker.read
			
			self.new(path, code: code, line_offset: line_offset, modified_time: modified_time)
		end
	end
end
