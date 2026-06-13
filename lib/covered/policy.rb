# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2018-2025, by Samuel Williams.

require_relative "summary"
require_relative "files"
require_relative "capture"
require_relative "persist"
require_relative "forks"

module Covered
	# Configures coverage collection, filtering, persistence and reports.
	class Policy < Wrapper
		# Initialize a policy with an empty file collection.
		def initialize
			super(Files.new)
			
			@reports = []
			@capture = nil
		end
		
		# @attribute [Covered::Base] The current output pipeline.
		attr :output
		
		# Freeze the policy and eagerly build the capture pipeline.
		# @returns [Covered::Policy] This frozen policy.
		def freeze
			return self if frozen?
			
			capture
			@reports.freeze
			
			super
		end
		
		# Include files matching the given pattern in coverage results.
		# Arguments are forwarded to {Covered::Include#initialize}.
		def include(...)
			@output = Include.new(@output, ...)
		end
		
		# Exclude files matching the given pattern from coverage results.
		# Arguments are forwarded to {Covered::Skip#initialize}.
		def skip(...)
			@output = Skip.new(@output, ...)
		end
		
		# Restrict coverage results to files matching the given pattern.
		# Arguments are forwarded to {Covered::Only#initialize}.
		def only(...)
			@output = Only.new(@output, ...)
		end
		
		# Restrict coverage results to the given project root.
		# Arguments are forwarded to {Covered::Root#initialize}.
		def root(...)
			@output = Root.new(@output, ...)
		end
		
		# Persist coverage results to a database.
		# Arguments are forwarded to {Covered::Persist#initialize}.
		def persist!(...)
			@output = Persist.new(@output, ...)
		end
		
		# The runtime capture pipeline for this policy.
		# @returns [Covered::Forks] The memoized capture pipeline.
		def capture
			@capture ||= Forks.new(
				Capture.new(@output)
			)
		end
		
		# Start collecting coverage.
		def start
			capture.start
		end
		
		# Finish collecting coverage.
		def finish
			capture.finish
		end
		
		# @attribute [Array] The configured report objects or autoloaders.
		attr :reports
		
		# Lazily loads a report class when it is first used.
		class Autoload
			# Initialize an autoloaded report with the given constant name.
			# @parameter name [String] The report class name under {Covered}.
			def initialize(name)
				@name = name
			end
			
			# Instantiate the report class.
			# @returns [Object] A new report instance.
			def new
				begin
					klass = Covered.const_get(@name)
				rescue NameError
					require_relative(snake_case(@name))
				end
				
				klass = Covered.const_get(@name)
				
				return klass.new
			end
			
			# Instantiate the report and call it.
			# Arguments are forwarded to the report.
			def call(...)
				self.new.call(...)
			end
			
			# A human-readable representation of this autoloaded report.
			# @returns [String] A debug representation of the autoloader.
			def to_s
				"\#<#{self.class} loading #{@name}>"
			end
			
			private
			
			def snake_case(string)
				return string.gsub(/::/, "/").
					gsub(/([A-Z]+)([A-Z][a-z])/,'\1_\2').
					gsub(/([a-z\d])([A-Z])/,'\1_\2').
					tr("-", "_").
					downcase
			end
		end
		
		# Configure reports from names, booleans, arrays or report objects.
		# @parameter reports [String | Boolean | Array | Object | Nil] The reports to configure.
		def reports!(reports)
			if reports.is_a?(String)
				names = reports.split(",")
				
				names.each do |name|
					begin
						klass = Covered.const_get(name)
						@reports << klass.new
					rescue NameError
						@reports << Autoload.new(name)
					end
				end
			elsif reports == true
				@reports << Covered::BriefSummary.new
			elsif reports == false
				@reports.clear
			elsif reports.is_a?(Array)
				@reports.concat(reports)
			else
				@reports << reports
			end
		end
		
		# Generate all configured reports.
		# Arguments are forwarded to each report.
		def call(...)
			@reports.each do |report|
				report.call(self, ...)
			end
		end
	end
end
