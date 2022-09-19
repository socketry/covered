# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2019-2022, by Samuel Williams.
# Copyright, 2022, by Adam Daniels.

require_relative 'config'

require 'minitest'

$covered = Covered::Config.load

module Covered
	module Minitest
		def run(*)
			$covered.enable
			
			super
		end
	end
end

if $covered.record?
	class << Minitest
		prepend Covered::Minitest
	end
	
	Minitest.after_run do
		$covered.disable
		$covered.call($stderr)
	end
end
