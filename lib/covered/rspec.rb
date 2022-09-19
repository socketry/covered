# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2018-2022, by Samuel Williams.

require_relative 'config'

require 'rspec/core/formatters'

$covered = Covered::Config.load

module Covered
	module RSpec
		class Formatter
			# The name `dump_summary` of this method is significant:
			::RSpec::Core::Formatters.register self, :dump_summary
			
			def initialize(output)
				@output = output
			end
			
			def dump_summary notification
				$covered.call(@output)
			end
		end
		
		module Policy
			def load_spec_files
				$covered.enable
				
				super
			end
			
			def covered
				$covered
			end
			
			def covered= policy
				$covered = policy
			end
		end
	end
end

if $covered.record?
	RSpec::Core::Configuration.prepend(Covered::RSpec::Policy)

	RSpec.configure do |config|
		config.add_formatter(Covered::RSpec::Formatter)
		
		config.after(:suite) do
			$covered.disable
		end
	end
end
