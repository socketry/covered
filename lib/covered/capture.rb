# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2018-2025, by Samuel Williams.

require_relative "wrapper"

begin
	require "ruby/coverage"
rescue LoadError => error
	raise error.exception("Covered::Capture requires the `ruby-coverage` gem. Add `gem \"ruby-coverage\", \"~> 0.1\"` to your bundle to record coverage.")
end

module Covered
	# Captures Ruby coverage data and forwards it to another coverage output.
	class Capture < Wrapper
		# Initialize capture with independent tracer state.
		def initialize(...)
			super
			
			@tracer = nil
			@files = {}
		end
		
		# Start Ruby coverage collection.
		def start
			super
			
			@files = {}
			@tracer = build_tracer
			@tracer.start
		end
		
		# Clear any collected coverage data without stopping coverage.
		def clear
			super
			
			@tracer&.stop
			@files = {}
			@tracer = build_tracer
			@tracer.start
		end
		
		EVAL_PATHS = {
			"(eval)" => true,
			"(irb)" => true,
			"eval" => true
		}
		
		# Stop coverage collection and add the collected results to the output.
		# Ignores Ruby's anonymous eval paths and files that no longer exist.
		def finish
			@tracer&.stop
			
			@files.each do |path, lines|
				next if EVAL_PATHS.include?(path)
				
				path = self.expand_path(path)
				
				# Skip files which don't exist. This can happen if `eval` is used with an invalid/incorrect path:
				if File.exist?(path)
					@output.mark(path, 0, lines)
				else
					# warn "Skipping coverage for #{path.inspect} because it doesn't exist!"
					# Ignore.
				end
			end
			
			@tracer = nil
			@files = {}
			
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
		
		private
		
		def build_tracer
			::Ruby::Coverage::Tracer.new do |path, iseq|
				@files[path] ||= begin
					lines = []
					::Ruby::Coverage.executable_lines(iseq).each do |line|
						lines[line] = 0
					end
					lines
				end
			end
		end
	end
end
