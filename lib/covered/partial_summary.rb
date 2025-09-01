# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2018-2025, by Samuel Williams.

require_relative "summary"

module Covered
	class PartialSummary < Summary
		def print_coverage(terminal, coverage, before: 4, after: 4)
			return if coverage.zero?
			
			line_offset = 1
			counts = coverage.counts
			last_line = nil
			
			coverage.read do |file|
				print_line_header(terminal)
				
				file.each_line do |line|
					range = Range.new([line_offset - before, 0].max, line_offset+after)
					
					if counts[range]&.include?(0)
						count = counts[line_offset]
						
						if last_line and last_line != line_offset-1
							terminal.puts ":".rjust(16)
						end
						
						print_annotations(terminal, coverage, line, line_offset)
						print_line(terminal, line, line_offset, count)
						
						last_line = line_offset
					end
					
					line_offset += 1
				end
			end
		end
		
		def call(wrapper, output = $stdout, **options)
			terminal = self.terminal(output)
			complete_files = []
			
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
			
			# Collect files with 100% coverage that were not shown
			wrapper.each do |coverage|
				if coverage.ratio >= 1.0
					complete_files << wrapper.relative_path(coverage.path)
				end
			end
			
			terminal.puts
			statistics.print(output)
			
			# Show information about files with 100% coverage
			if complete_files.any?
				terminal.puts ""
				if complete_files.size == 1
					terminal.puts "1 file has 100% coverage and is not shown above:"
				else
					terminal.puts "#{complete_files.size} files have 100% coverage and are not shown above:"
				end
				
				complete_files.sort.each do |path|
					terminal.write "  - ", style: :covered_prefix
					terminal.puts path, style: :brief_path
				end
			end
		end
	end
end
