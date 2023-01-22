# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2018-2022, by Samuel Williams.

module Covered
	module Ratio
		def ratio
			return 1 if executable_count.zero?
			
			Rational(executed_count, executable_count)
		end
		
		def complete?
			executed_count == executable_count
		end
		
		def percentage
			ratio * 100
		end
	end
	
	class Source
		def self.for(path, code, line_offset)
			self.new(path, code: code, line_offset: line_offset)
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
	
	class Coverage
		class Summary
			include Ratio
			
			def initialize(counts)
				@counts = counts
			end
			
			attr :counts
			
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
		end
		
		def self.for(path, **options)
			self.new(Source.new(path, **options))
		end
		
		def initialize(source, counts = [], total = 0, annotations = {})
			@source = source
			@counts = counts
			@total = total
			@annotations = annotations
			
			# Cached summary:
			@summary = nil
		end
		
		def merge!(coverage)
			@counts = @counts.zip(coverage.counts).map do |a, b|
				if a || b
					(a || 0) + (b || 0)
				end
			end
			
			@total += coverage.total
			
			coverage.annotations.each do |lineno, annotation|
				annotate(lineno, annotation)
			end
			
			return self
		end
		
		def path
			@source.path
		end
		
		def path= value
			@source.path = value
		end
		
		def fresh?
			if @source.modified_time.nil?
				# We don't know when the file was last modified, so we assume it is fresh:
				return true
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
			@summary ||= self.summary
			
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
		
		def annotate(lineno, annotation)
			@annotations[lineno] ||= []
			@annotations[lineno] << annotation
		end
		
		def mark(lineno, value = 1)
			@total += value
			
			if @counts[lineno]
				@counts[lineno] += value
			else
				@counts[lineno] = value
			end
		end
		
		def summary
			@summary || Summary.new(@counts)
		end
		
		def print(output)
			self.summary.print(output)
		end
		
		def to_s
			"\#<#{self.class} path=#{self.path} #{self.summary.percentage.to_f.round(2)}% covered>"
		end
		
		def serialize(packer)
			packer.write(@source)
			packer.write(@counts)
			packer.write(@total)
			packer.write(@annotations)
		end
		
		def self.deserialize(unpacker)
			source = unpacker.read
			counts = unpacker.read
			total = unpacker.read
			annotations = unpacker.read
			
			self.new(source, counts, total, annotations)
		end
	end
end
