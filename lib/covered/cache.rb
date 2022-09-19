# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2022, by Samuel Williams.

require_relative 'wrapper'

require 'coverage'

module Covered
	class Cache < Wrapper
		def initialize(output)
			super(output)
			
			@marks = nil
		end
		
		def mark(path, lineno, count = 1)
			if @marks
				@marks.push(path, lineno, count)
			else
				super
			end
		end
		
		def enable
			@marks = []
			
			super
		end
		
		def flush
			if @marks
				@marks.each_slice(3) do |path, lineno, count|
					@output.mark(path, lineno, count)
				end
				
				@marks = nil
			end
			
			super
		end
		
		def disable
			super
			
			flush
		end
	end
end
