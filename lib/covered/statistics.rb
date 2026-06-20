# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2018-2025, by Samuel Williams.

require_relative "wrapper"
require_relative "coverage"

module Covered
	# Raised when coverage does not meet the configured minimum.
	class CoverageError < StandardError
	end
	
	# Aggregates coverage statistics across files.
	class Statistics
		include Ratio
		
		# Build statistics for a single coverage object.
		# @parameter coverage [Covered::Coverage] The coverage object to summarize.
		# @returns [Covered::Statistics] Statistics containing the given coverage.
		def self.for(coverage)
			self.new.tap do |statistics|
				statistics << coverage
			end
		end
		
		# Aggregate coverage totals.
		class Aggregate
			include Ratio
			
			# Initialize empty aggregate statistics.
			def initialize
				@count = 0
				@executable_count = 0
				@executed_count = 0
			end
			
			# Total number of files added.
			# @returns [Integer] The number of covered files.
			attr :count
			
			# The number of lines which could have been executed.
			# @returns [Integer] The executable line count.
			attr :executable_count
			
			# The number of lines that were executed.
			# @returns [Integer] The executed line count.
			attr :executed_count
			
			# A JSON-compatible representation of these aggregate statistics.
			# @returns [Hash] The aggregate count, line counts and percentage.
			def as_json
				{
					count: count,
					executable_count: executable_count,
					executed_count: executed_count,
					percentage: percentage.to_f.round(2),
				}
			end
			
			# Convert these aggregate statistics to JSON.
			# @parameter options [Hash] Options forwarded to `to_json`.
			# @returns [String] The JSON representation.
			def to_json(options)
				as_json.to_json(options)
			end
			
			# Add coverage to these aggregate statistics.
			# @parameter coverage [Covered::Coverage] The coverage object to add.
			def << coverage
				add(1, coverage.executable_count, coverage.executed_count)
			end
			
			# Add counts to these aggregate statistics.
			# @parameter count [Integer] The number of files to add.
			# @parameter executable_count [Integer] The number of executable lines to add.
			# @parameter executed_count [Integer] The number of executed lines to add.
			def add(count, executable_count, executed_count)
				@count += count
				@executable_count += executable_count
				@executed_count += executed_count
			end
		end
		
		# Initialize empty coverage statistics.
		def initialize
			@total = Aggregate.new
			@paths = Hash.new
		end
		
		# @attribute [Covered::Statistics::Aggregate] The total aggregate statistics.
		attr :total
		
		# @attribute [Hash(String, Covered::Coverage)] Coverage statistics indexed by path.
		attr :paths
		
		# The number of unique paths with coverage data.
		# @returns [Integer] The number of unique paths.
		def count
			@paths.size
		end
		
		# The total number of executable lines.
		# @returns [Integer] The total executable line count.
		def executable_count
			total.executable_count
		end
		
		# The total number of executed lines.
		# @returns [Integer] The total executed line count.
		def executed_count
			total.executed_count
		end
		
		# Add coverage to these statistics.
		# @parameter coverage [Covered::Coverage] The coverage object to add.
		def << coverage
			current = @paths[coverage.path]
			count = 0
			
			unless current
				current = @paths[coverage.path] = coverage.empty
				count = 1
			end
			
			executable_count = current.executable_count
			executed_count = current.executed_count
			
			current.merge!(coverage)
			
			@total.add(
				count,
				current.executable_count - executable_count,
				current.executed_count - executed_count
			)
		end
		
		# Get coverage for the given path.
		# @parameter path [String] The source path.
		# @returns [Covered::Coverage | Nil] The merged coverage for the path.
		def [](path)
			@paths[path]
		end
		
		# A JSON-compatible representation of these statistics.
		# @returns [Hash] The total statistics and path statistics.
		def as_json
			{
				total: total.as_json,
				paths: @paths.map{|path, coverage| [path, coverage.as_json]}.to_h,
			}
		end
		
		# Convert these statistics to JSON.
		# @parameter options [Hash] Options forwarded to `to_json`.
		# @returns [String] The JSON representation.
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
		
		# Print a human-readable coverage summary.
		# @parameter output [IO] The output stream.
		def print(output)
			output.puts "#{count} files checked; #{@total.executed_count}/#{@total.executable_count} lines executed; #{@total.percentage.to_f.round(2)}% covered."
			
			if self.complete?
				output.puts "🧘 #{COMPLETE.sample}"
			end
		end
		
		# Validate that coverage meets the given minimum ratio.
		# @parameter minimum [Numeric] The minimum accepted coverage ratio.
		# @raises [Covered::CoverageError] If coverage is below the minimum ratio.
		def validate!(minimum = 1.0)
			if total.ratio < minimum
				raise CoverageError, "Coverage of #{self.percentage.to_f.round(2)}% is less than required minimum of #{(minimum * 100.0).round(2)}%!"
			end
		end
	end
end
