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
	
	class Coverage
		def initialize(path, counts = [])
			@path = path
			@counts = counts
			@total = 0
			
			@annotations = {}
			
			@executable_lines = nil
			@executed_lines = nil
		end
		
		attr :path
		attr :counts
		attr :total
		
		attr :annotations
		
		def read(&block)
			if block_given?
				File.open(@path, "r", &block)
			else
				File.read(@path)
			end
		end
		
		def freeze
			return self if frozen?
			
			@counts.freeze
			@annotations.freeze
			
			executable_lines
			executed_lines
			
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
		
		include Ratio
		
		def print(output)
			output.puts "** #{executed_count}/#{executable_count} lines executed; #{percentage.to_f.round(2)}% covered."
		end
		
		def to_s
			"\#<#{self.class} path=#{@path} #{percentage.to_f.round(2)}% covered>"
		end
	end
end
