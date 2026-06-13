# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2018-2025, by Samuel Williams.

require_relative "config"
require "rspec/core/formatters"

$covered = Covered::Config.load

module Covered
	# Integrates coverage tracking with RSpec.
	module RSpec
		# Extends RSpec configuration with coverage tracking.
		module Policy
			# Start coverage before loading spec files.
			# @returns [Object] The result of RSpec's original `load_spec_files` method.
			def load_spec_files
				$covered.start
				
				super
			end
			
			# The active coverage configuration.
			# @returns [Covered::Config] The active coverage configuration.
			def covered
				$covered
			end
			
			# Assign the active coverage configuration.
			# @parameter policy [Covered::Config] The replacement coverage configuration.
			def covered= policy
				$covered = policy
			end
		end
	end
end

if $covered.record?
	RSpec::Core::Configuration.prepend(Covered::RSpec::Policy)
	
	RSpec.configure do |config|
		config.after(:suite) do
			$covered.finish
			$covered.call(config.output_stream)
		end
	end
end
