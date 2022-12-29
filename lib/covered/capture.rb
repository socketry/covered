# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2018-2022, by Samuel Williams.

require_relative 'wrapper'

require 'coverage'

module Covered
	class Capture < Wrapper
		def enable
			super
			
			::Coverage.start(lines: true, eval: true)
		end
		
		def disable
			results = ::Coverage.result

			results.each do |path, result|
				lines = result[:lines]

				lines.each_with_index do |count, lineno|
					@output.mark(path, lineno+1, count) if count
				end
			end
	
			super
		end

		def execute(source, binding: TOPLEVEL_BINDING)
			enable
			
			eval(source.code!, binding, source.path, source.line_offset)
		ensure
			disable
		end
	end
end
