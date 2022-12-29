# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2022, by Samuel Williams.

require_relative 'config'

module Coverage
	# Start recording coverage information.
	# Usage: RUBYOPT=-rcovered/start ruby -e '...'
	def self.autostart!
		config = Covered::Config.load
		config.enable
		
		pid = Process.pid
		
		at_exit do
			# Don't break forked children:
			if Process.pid == pid
				config.disable
			end
		end
	end
end

Coverage.autostart!
