# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2021-2025, by Samuel Williams.

require_relative "statistics"
require_relative "wrapper"

require "console/output"

module Covered
	# Generates a Markdown coverage summary.
	class MarkdownSummary
		# Initialize the report with an optional coverage threshold.
		# @parameter threshold [Numeric | Nil] The minimum ratio a file must meet to be omitted from the detailed output.
		def initialize(threshold: 1.0)
			@threshold = threshold
		end
		
		# Enumerate coverage below the threshold and return aggregate statistics.
		# @parameter wrapper [Covered::Base] The coverage wrapper to enumerate.
		# @yields {|coverage| ...} Coverage whose ratio is below the configured threshold.
		# 	@parameter coverage [Covered::Coverage] The coverage object below the threshold.
		# @returns [Covered::Statistics] Statistics for all coverage objects, including omitted ones.
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
		
		# Print any annotations for the given line.
		# @parameter output [IO] The output stream.
		# @parameter coverage [Covered::Coverage] The coverage being rendered.
		# @parameter line [String] The source line.
		# @parameter line_offset [Integer] The current line number.
		def print_annotations(output, coverage, line, line_offset)
			if annotations = coverage.annotations[line_offset]
				prefix = "#{line_offset}|".rjust(8) + "*|".rjust(8)
				output.write prefix
				
				output.write line.match(/^\s+/)
				output.puts "\# #{annotations.join(", ")}"
			end
		end
		
		# Print the line and hit-count header.
		# @parameter output [IO] The output stream.
		def print_line_header(output)
			output.puts "Line|".rjust(8) + "Hits|".rjust(8)
		end
		
		# Print a single source line.
		# @parameter output [IO] The output stream.
		# @parameter line [String] The source line.
		# @parameter line_offset [Integer] The current line number.
		# @parameter count [Integer | Nil] The execution count for the line.
		def print_line(output, line, line_offset, count)
			prefix = "#{line_offset}|".rjust(8) + "#{count}|".rjust(8)
			
			output.write prefix
			output.write line
			
			# If there was no newline at end of file, we add one:
			unless line.end_with?($/)
				output.puts
			end
		end
		
		# A coverage array gives, for each line, the number of line executions by the interpreter. A `nil` value means coverage is finished for this line (lines like `else` and `end`).
		# @parameter wrapper [Covered::Base] The coverage wrapper to report.
		# @parameter output [IO] The output stream.
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
