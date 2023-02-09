# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2018-2022, by Samuel Williams.

require_relative "summary"
require_relative "files"
require_relative "capture"
require_relative "persist"
require_relative "forks"

module Covered
	class Policy < Wrapper
		def initialize
			super(Files.new)
			
			@reports = []
			@capture = nil
		end
		
		attr :output
		
		def freeze
			return self if frozen?
			
			capture
			@reports.freeze
			
			super
		end
		
		def include(...)
			@output = Include.new(@output, ...)
		end
		
		def skip(...)
			@output = Skip.new(@output, ...)
		end
		
		def only(...)
			@output = Only.new(@output, ...)
		end
		
		def root(...)
			@output = Root.new(@output, ...)
		end
		
		def persist!(...)
			@output = Persist.new(@output, ...)
		end
		
		def capture
			@capture ||= Forks.new(
				Capture.new(@output)
			)
		end
		
		def start
			capture.start
		end
		
		def finish
			capture.finish
		end
		
		attr :reports
		
		class Autoload
			def initialize(name)
				@name = name
			end
			
			def new
				begin
					klass = Covered.const_get(@name)
				rescue NameError
					require_relative(snake_case(@name))
				end
				
				klass = Covered.const_get(@name)
				
				return klass.new
			end
			
			def call(...)
				self.new.call(...)
			end
			
			def to_s
				"\#<#{self.class} loading #{@name}>"
			end
			
			private
			
			def snake_case(string)
				return string.gsub(/::/, '/').
					gsub(/([A-Z]+)([A-Z][a-z])/,'\1_\2').
					gsub(/([a-z\d])([A-Z])/,'\1_\2').
					tr("-", "_").
					downcase
			end
		end
		
		def reports!(coverage)
			if coverage.is_a?(String)
				names = coverage.split(',')
				
				names.each do |name|
					begin
						klass = Covered.const_get(name)
						@reports << klass.new
					rescue NameError
						@reports << Autoload.new(name)
					end
				end
			elsif coverage
				@reports << Covered::BriefSummary.new
			end
		end
		
		def call(...)
			@reports.each do |report|
				report.call(self, ...)
			end
		end
	end
end
