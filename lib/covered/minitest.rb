# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2019-2025, by Samuel Williams.
# Copyright, 2022, by Adam Daniels.

require_relative "config"

require "minitest"

$covered = Covered::Config.load

module Covered
	module Minitest
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
	end
end
