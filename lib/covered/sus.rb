# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2019-2025, by Samuel Williams.

module Covered
	module Sus
		def initialize(...)
			super
			
			# Defer loading the coverage configuration unless we are actually running with coverage startd to avoid performance cost/overhead.
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
		
		def after_tests(assertions)
			super(assertions)
			
			if @covered&.record?
				@covered.finish
				@covered.call(self.output.io)
			end
		end
		
		def covered
			@covered
		end
	end
end
