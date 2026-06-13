# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2019-2025, by Samuel Williams.

module Covered
	# Integrates coverage tracking with Sus.
	module Sus
		# Initialize Sus with optional coverage tracking.
		# Loads and starts coverage only when the `COVERAGE` environment variable is set.
		def initialize(...)
			super
			
			# Defer loading the coverage configuration unless we are actually running with coverage started to avoid performance cost/overhead:
			if ENV["COVERAGE"]
				require_relative "config"
				
				@covered = Covered::Config.load(root: self.root)
				if @covered.record?
					@covered.start
				end
			else
				@covered = nil
			end
		end
		
		# Finish coverage tracking after tests complete.
		# @parameter assertions [Object] The assertions object passed through to Sus.
		def after_tests(assertions)
			super(assertions)
			
			if @covered&.record?
				@covered.finish
				@covered.call(self.output.io)
			end
		end
		
		# The active coverage configuration.
		# @returns [Covered::Config | Nil] The active coverage configuration when coverage is enabled.
		def covered
			@covered
		end
	end
end
