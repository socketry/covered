# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2025, by Samuel Williams.

require_relative "summary"

module Covered
	class BriefSummary < Summary
		def call(wrapper, output = $stdout, before: 4, after: 4)
			terminal = self.terminal(output)
			
			ordered = []
			
			statistics = self.each(wrapper) do |coverage|
				ordered << coverage unless coverage.complete?
			end
			
			terminal.puts
			statistics.print(output)
			
			if ordered.any?
				terminal.puts "", "Least Coverage:"
				ordered.sort_by!(&:missing_count).reverse!
				
				ordered.first(5).each do |coverage|
					path = wrapper.relative_path(coverage.path)
					
					terminal.write path, style: :brief_path
					terminal.puts ": #{coverage.missing_count} lines not executed!"
				end
			end
		end
	end
end
