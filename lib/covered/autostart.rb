# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2023-2025, by Samuel Williams.

require_relative "config"

module Coverage
	module Autostart
		# Start recording coverage information.
		# Usage: RUBYOPT=-rcovered/autostart ruby my_script.rb
		def self.autostart!
			config = Covered::Config.load
			config.start
			
			pid = Process.pid
			
			at_exit do
				# Don't break forked children:
				if Process.pid == pid
					config.finish
					
					if config.report?
						config.call($stderr)
					end
				end
			end
		end
	end
end

Coverage::Autostart.autostart!
