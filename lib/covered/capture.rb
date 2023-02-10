# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2018-2023, by Samuel Williams.

require_relative 'wrapper'

require 'coverage'

module Covered
	class Capture < Wrapper
		def start
			super
			
			::Coverage.start(lines: true, eval: true)
		end
		
		def clear
			super
			
			::Coverage.result(stop: false, clear: true)
		end
		
		def finish
			results = ::Coverage.result
			
			results.each do |path, result|
				lines = result[:lines]
				path = self.expand_path(path)
				
				lines.each_with_index do |count, lineno|
					@output.mark(path, lineno+1, count) if count
				end
			end
			
			super
		end
		
		def execute(source, binding: TOPLEVEL_BINDING)
			start
			
			eval(source.code!, binding, source.path, source.line_offset)
		ensure
			finish
		end
	end
end
