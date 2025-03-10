# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2019-2025, by Samuel Williams.
# Copyright, 2022, by Adam Daniels.

require_relative "config"

require "minitest"

$covered = Covered::Config.load

module Covered
	module Minitest
		MINIMUM_COVERAGE =
			Float(ENV.fetch('MINIMUM_COVERAGE', 100.0))

		def run(*)
			$covered.start
			
			super
		end
	end
end

if $covered.record?
	Minitest.singleton_class.prepend(Covered::Minitest)
	
	Minitest.after_run do
		$covered.finish
		$covered.call($stderr)

		stats = Covered::Statistics.new

		$covered.policy.each { stats << _1 }

		stats.validate! Covered::Minitest::MINIMUM_COVERAGE / 100.0
	end
end
