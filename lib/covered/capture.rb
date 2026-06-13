# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2018-2025, by Samuel Williams.

require_relative "wrapper"

require "coverage"

module Covered
	# Captures Ruby coverage data and forwards it to another coverage output.
	class Capture < Wrapper
		# Start Ruby coverage collection.
		def start
			super
			
			::Coverage.start(lines: true, eval: true)
		end
		
		# Clear any collected coverage data without stopping coverage.
		def clear
			super
			
			::Coverage.result(stop: false, clear: true)
		end
		
		EVAL_PATHS = {
			"(eval)" => true,
			"(irb)" => true,
			"eval" => true
		}
		
		# Stop coverage collection and add the collected results to the output.
		# Ignores Ruby's anonymous eval paths and files that no longer exist.
		def finish
			results = ::Coverage.result
			
			results.each do |path, result|
				next if EVAL_PATHS.include?(path)
				
				path = self.expand_path(path)
				
				# Skip files which don't exist. This can happen if `eval` is used with an invalid/incorrect path:
				if File.exist?(path)
					@output.mark(path, 1, result[:lines])
				else
					# warn "Skipping coverage for #{path.inspect} because it doesn't exist!"
					# Ignore.
				end
			end
			
			super
		end
		
		# Execute the given source while capturing coverage for it.
		# @parameter source [Covered::Source] The source to execute.
		# @parameter binding [Binding] The binding used to evaluate the source.
		# @returns [Object] The result of evaluating the source.
		def execute(source, binding: TOPLEVEL_BINDING)
			start
			
			eval(source.code!, binding, source.path, source.line_offset)
		ensure
			finish
		end
	end
end
