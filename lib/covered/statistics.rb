# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2018-2023, by Samuel Williams.

require_relative 'wrapper'
require_relative 'coverage'

module Covered
	class CoverageError < StandardError
	end
	
	class Statistics < Wrapper
		def self.for(coverage)
			self.new.tap do |statistics|
				statistics << coverage
			end
		end
		
		def initialize
			@count = 0
			@executable_count = 0
			@executed_count = 0
		end
		
		# Total number of files added.
		attr :count
		
		# The number of lines which could have been executed.
		attr :executable_count
		
		# The number of lines that were executed.
		attr :executed_count
		
		def as_json
			{
				count: count,
				executable_count: executable_count,
				executed_count: executed_count,
				percentage: percentage.to_f.round(2),
			}
		end
		
		def to_json(options)
			as_json.to_json(options)
		end
		
		def << coverage
			@count += 1
			
			@executable_count += coverage.executable_count
			@executed_count += coverage.executed_count
		end
		
		include Ratio
		
		def print(output)
			output.puts "* #{count} files checked; #{executed_count}/#{executable_count} lines executed; #{percentage.to_f.round(2)}% covered."
			
			# Could output funny message here, especially for 100% coverage.
		end
		
		def validate!(minimum = 1.0)
			if self.ratio < minimum
				raise CoverageError, "Coverage of #{self.percentage.to_f.round(2)}% is less than required minimum of #{(minimum * 100.0).round(2)}%!"
			end
		end
	end
end
