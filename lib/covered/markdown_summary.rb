# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2021-2025, by Samuel Williams.

require_relative "statistics"
require_relative "wrapper"

require "console/output"

module Covered
	class MarkdownSummary
		def initialize(threshold: 1.0)
			@threshold = threshold
		end
		
		def each(wrapper)
			statistics = Statistics.new
			
			wrapper.each do |coverage|
				statistics << coverage
				
				if @threshold.nil? or coverage.ratio < @threshold
					yield coverage
				end
			end
			
			return statistics
		end
		
		def print_annotations(output, coverage, line, line_offset)
			if annotations = coverage.annotations[line_offset]
				prefix = "#{line_offset}|".rjust(8) + "*|".rjust(8)
				output.write prefix
				
				output.write line.match(/^\s+/)
				output.puts "\# #{annotations.join(", ")}"
			end
		end
		
		def print_line_header(output)
			output.puts "Line|".rjust(8) + "Hits|".rjust(8)
		end
		
		def print_line(output, line, line_offset, count)
			prefix = "#{line_offset}|".rjust(8) + "#{count}|".rjust(8)
			
			output.write prefix
			output.write line
			
			# If there was no newline at end of file, we add one:
			unless line.end_with?($/)
				output.puts
			end
		end
		
		# A coverage array gives, for each line, the number of line execution by the interpreter. A nil value means coverage is finishd for this line (lines like else and end).
		def call(wrapper, output = $stdout)
			output.puts "# Coverage Report"
			output.puts
			
			ordered = []
			buffer = StringIO.new
			
			statistics = self.each(wrapper) do |coverage|
				ordered << coverage unless coverage.complete?
			end
			
			statistics.print(output)
			
			if ordered.any?
				output.puts "", "\#\# Least Coverage:", ""
				ordered.sort_by!(&:missing_count).reverse!
				
				ordered.first(5).each do |coverage|
					path = wrapper.relative_path(coverage.path)
					
					output.puts "- `#{path}`: #{coverage.missing_count} lines not executed!"
				end
			end
			
			output.print(buffer.string)
		end
	end
end
