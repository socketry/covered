# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2023-2025, by Samuel Williams.

require_relative "wrapper"

module Covered
	# Tracks coverage across forked child processes.
	class Forks < Wrapper
		# Start tracking coverage and install the fork handler.
		def start
			super
			
			Handler.start(self)
		end
		
		# Stop tracking coverage and remove the fork handler state.
		def finish
			Handler.finish
			
			super
		end
		
		# Handles `Process.fork` so child processes record coverage independently.
		module Handler
			LOCK = Mutex.new
			
			class << self
				# @attribute [Covered::Forks | Nil] The currently registered coverage wrapper.
				attr :coverage
				
				# Register coverage for fork handling.
				# @parameter coverage [Covered::Forks] The coverage wrapper to use in forked children.
				# @raises [ArgumentError] If coverage is already registered.
				def start(coverage)
					LOCK.synchronize do
						if @coverage
							raise ArgumentError, "Coverage is already being tracked!"
						end
						
						@coverage = coverage
					end
				end
				
				# Clear the registered coverage.
				def finish
					LOCK.synchronize do
						@coverage = nil
					end
				end
				
				# Reset coverage in a forked child and save it at exit.
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
			
			# Intercept `Process.fork` and initialize coverage in the child.
			# @returns [Integer | Nil] The process ID in the parent, and `0` or `nil` in the child depending on Ruby's fork semantics.
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
