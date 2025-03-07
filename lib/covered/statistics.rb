# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2018-2025, by Samuel Williams.

require_relative "wrapper"
require_relative "coverage"

module Covered
	class CoverageError < StandardError
	end
	
	class Statistics
		include Ratio
		
		def self.for(coverage)
			self.new.tap do |statistics|
				statistics << coverage
			end
		end
		
		class Aggregate
			include Ratio
			
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
		end
		
		def initialize
			@total = Aggregate.new
			@paths = Hash.new
		end
		
		attr :total
		attr :paths
		
		def count
			@paths.size
		end
		
		def executable_count
			@total.executable_count
		end
		
		def executed_count
			@total.executed_count
		end
		
		def << coverage
			@total << coverage
			(@paths[coverage.path] ||= coverage.empty).merge!(coverage)
		end
		
		def [](path)
			@paths[path]
		end
		
		def as_json
			{
				total: total.as_json,
				paths: @paths.map{|path, coverage| [path, coverage.as_json]}.to_h,
			}
		end
		
		def to_json(options)
			as_json.to_json(options)
		end
		
		COMPLETE = [
			"Enter the code dojo: 100% coverage attained, bugs defeated with one swift strike.",
			"Nirvana reached: 100% code coverage, where bugs meditate and vanish like a passing cloud.",
			"With 100% coverage, your code has unlocked the path to enlightenment – bugs have no place to hide.",
			"In the realm of code serenity, 100% coverage is your ticket to coding enlightenment.",
			"100% coverage, where code and bugs coexist in perfect harmony, like Yin and Yang.",
			"Achieving the Zen of code coverage, your code is a peaceful garden where bugs find no shelter.",
			"Congratulations on coding enlightenment! 100% coverage means your code is one with the universe.",
			"With 100% coverage, your code is a tranquil pond where bugs cause no ripples.",
			"At the peak of code mastery: 100% coverage, where bugs bow down before the wisdom of your code.",
			"100% code coverage: Zen achieved! Bugs in harmony, code at peace.",
		]
		
		def print(output)
			output.puts "#{count} files checked; #{@total.executed_count}/#{@total.executable_count} lines executed; #{@total.percentage.to_f.round(2)}% covered."
			
			if self.complete?
				output.puts "🧘 #{COMPLETE.sample}"
			end
		end
		
		def validate!(minimum = 1.0)
			if total.ratio < minimum
				raise CoverageError, "Coverage of #{self.percentage.to_f.round(2)}% is less than required minimum of #{(minimum * 100.0).round(2)}%!"
			end
		end
	end
end
