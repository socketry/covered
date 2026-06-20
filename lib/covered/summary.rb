# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2018-2025, by Samuel Williams.

require_relative "statistics"
require_relative "wrapper"

module Covered
	# Generates a detailed terminal coverage report.
	class Summary
		# Initialize the report with an optional coverage threshold.
		# @parameter threshold [Numeric | Nil] The minimum ratio a file must meet to be omitted from the detailed output.
		def initialize(threshold: 1.0)
			@threshold = threshold
		end
		
		# Build a styled terminal for the given output.
		# @parameter output [IO] The output stream.
		# @returns [Console::Terminal] The styled terminal wrapper.
		def terminal(output)
			require "console/terminal"
			
			Console::Terminal.for(output).tap do |terminal|
				terminal[:path] ||= terminal.style(nil, nil, :bold, :underline)
				terminal[:brief_path] ||= terminal.style(:yellow)
				
				terminal[:uncovered_prefix] ||= terminal.style(:red)
				terminal[:covered_prefix] ||= terminal.style(:green)
				terminal[:ignored_prefix] ||= terminal.style(nil, nil, :faint)
				terminal[:header_prefix] ||= terminal.style(nil, nil, :faint)
				
				terminal[:uncovered_code] ||= terminal.style(:red)
				terminal[:covered_code] ||= terminal.style(:green)
				terminal[:ignored_code] ||= terminal.style(nil, nil, :faint)
				
				terminal[:annotations] ||= terminal.style(:blue)
				terminal[:error] ||= terminal.style(:red)
			end
		end
		
		# Enumerate coverage below the threshold and return aggregate statistics.
		# @parameter wrapper [Covered::Base] The coverage wrapper to enumerate.
		# @yields {|coverage| ...} Coverage whose ratio is below the configured threshold.
		# 	@parameter coverage [Covered::Coverage] The coverage object below the threshold.
		# @returns [Covered::Statistics] Statistics for all coverage objects, including omitted ones.
		def each(wrapper)
			coverages = []
			
			wrapper.each do |coverage|
				coverages << coverage
				
				if @threshold.nil? or coverage.ratio < @threshold
					yield coverage
				end
			end
			
			return Statistics.new(Statistics::Aggregate.new(coverages))
		end
		
		# Print any annotations for the given line.
		# @parameter terminal [Console::Terminal] The terminal to write to.
		# @parameter coverage [Covered::Coverage] The coverage being rendered.
		# @parameter line [String] The source line.
		# @parameter line_offset [Integer] The current line number.
		def print_annotations(terminal, coverage, line, line_offset)
			if annotations = coverage.annotations[line_offset]
				prefix = "#{line_offset}|".rjust(8) + "*|".rjust(8)
				terminal.write prefix, style: :ignored_prefix
				
				terminal.write line.match(/^\s+/)
				terminal.puts "\# #{annotations.join(", ")}", style: :annotations
			end
		end
		
		# Print the line and hit-count header.
		# @parameter terminal [Console::Terminal] The terminal to write to.
		def print_line_header(terminal)
			prefix = "Line|".rjust(8) + "Hits|".rjust(8)
			
			terminal.puts prefix, style: :header_prefix
		end
		
		# Print a single source line with coverage styling.
		# @parameter terminal [Console::Terminal] The terminal to write to.
		# @parameter line [String] The source line.
		# @parameter line_offset [Integer] The current line number.
		# @parameter count [Integer | Nil] The execution count for the line.
		def print_line(terminal, line, line_offset, count)
			prefix = "#{line_offset}|".rjust(8) + "#{count}|".rjust(8)
			
			if count == nil
				terminal.write prefix, style: :ignored_prefix
				terminal.write line, style: :ignored_code
			elsif count == 0
				terminal.write prefix, style: :uncovered_prefix
				terminal.write line, style: :uncovered_code
			else
				terminal.write prefix, style: :covered_prefix
				terminal.write line, style: :covered_code
			end
			
			# If there was no newline at end of file, we add one:
			unless line.end_with? $/
				terminal.puts
			end
		end
		
		# Print line-by-line coverage for one source file.
		# @parameter terminal [Console::Terminal] The terminal to write to.
		# @parameter coverage [Covered::Coverage] The coverage to render.
		def print_coverage(terminal, coverage)
			line_offset = 1
			counts = coverage.counts
			
			coverage.read do |file|
				print_line_header(terminal)
				
				file.each_line do |line|
					count = counts[line_offset]
					
					print_annotations(terminal, coverage, line, line_offset)
					
					print_line(terminal, line, line_offset, count)
					
					line_offset += 1
				end
			end
		end
		
		# Print an error raised while rendering coverage.
		# @parameter terminal [Console::Terminal] The terminal to write to.
		# @parameter error [Exception] The rendering error.
		def print_error(terminal, error)
			terminal.puts "Error: #{error.message}", style: :error
			terminal.puts error.backtrace
		end
		
		# Print the detailed coverage report.
		# A coverage array gives, for each line, the number of line executions by the interpreter. A `nil` value means coverage is finished for this line (lines like `else` and `end`).
		# @parameter wrapper [Covered::Base] The coverage wrapper to report.
		# @parameter output [IO] The output stream.
		# @parameter options [Hash] Options forwarded to {print_coverage}.
		def call(wrapper, output = $stdout, **options)
			terminal = self.terminal(output)
			
			statistics = self.each(wrapper) do |coverage|
				path = wrapper.relative_path(coverage.path)
				terminal.puts ""
				terminal.puts path, style: :path
				
				begin
					print_coverage(terminal, coverage, **options)
				rescue => error
					print_error(terminal, error)
				end
				
				coverage.print(output)
			end
			
			terminal.puts
			statistics.print(output)
		end
	end
	
	# Generates a detailed report without applying a coverage threshold.
	class FullSummary < Summary
		# Initialize a full summary report.
		def initialize
			super(threshold: nil)
		end
	end
	
	# Suppresses coverage report output.
	class Quiet
		# Generate no output.
		# @parameter wrapper [Covered::Base] The coverage wrapper to ignore.
		# @parameter output [IO] The output stream to ignore.
		def call(wrapper, output = $stdout)
			# Silent.
		end
	end
end
