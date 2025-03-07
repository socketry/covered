# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2018-2025, by Samuel Williams.

require_relative "wrapper"

require "coverage"

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
		
		EVAL_PATHS = {
			"(eval)" => true,
			"(irb)" => true,
			"eval" => true
		}
		
		def finish
			results = ::Coverage.result
			
			results.each do |path, result|
				next if EVAL_PATHS.include?(path)
				
				path = self.expand_path(path)
				
				# Skip files which don't exist. This can happen if `eval` is used with an invalid/incorrect path.
				if File.exist?(path)
					@output.mark(path, 1, result[:lines])
				else
					# warn "Skipping coverage for #{path.inspect} because it doesn't exist!"
					# Ignore.
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
