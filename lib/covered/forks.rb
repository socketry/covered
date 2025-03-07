# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2023-2025, by Samuel Williams.

require_relative "wrapper"

module Covered
	class Forks < Wrapper
		def start
			super
			
			Handler.start(self)
		end
		
		def finish
			Handler.finish
			
			super
		end
		
		module Handler
			LOCK = Mutex.new
			
			class << self
				attr :coverage
				
				def start(coverage)
					LOCK.synchronize do
						if @coverage
							raise ArgumentError, "Coverage is already being tracked!"
						end
						
						@coverage = coverage
					end
				end
				
				def finish
					LOCK.synchronize do
						@coverage = nil
					end
				end
				
				def after_fork
					return unless coverage = Handler.coverage
					pid = Process.pid
					
					# Any pre-existing coverage is being tracked by the parent process, so discard it.
					coverage.clear
					
					at_exit do
						# Don't break forked children:
						if Process.pid == pid
							coverage.finish
						end
					end
				end
			end
			
			def _fork
				pid = super
				
				if pid.zero?
					Handler.after_fork
				end
				
				return pid
			end
			
			::Process.singleton_class.prepend(self)
		end
		
		private_constant :Handler
	end
end
