# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2018-2022, by Samuel Williams.

require_relative "summary"
require_relative "files"
require_relative "capture"
require_relative "persist"

module Covered
	class Policy < Wrapper
		def initialize
			super(Files.new)
			
			@reports = []
		end
		
		attr :output
		
		def freeze
			return self if frozen?
			
			capture
			@reports.freeze
			
			super
		end
		
		def include(*args)
			@output = Include.new(@output, *args)
		end
		
		def skip(*args)
			@output = Skip.new(@output, *args)
		end
		
		def only(*args)
			@output = Only.new(@output, *args)
		end
		
		def root(*args)
			@output = Root.new(@output, *args)
		end
		
		def persist!
			@output = Persist.new(@output)
		end
		
		def capture
			@capture ||= Capture.new(@output)
		end
		
		def enable
			capture.enable
		end
		
		def disable
			capture.disable
		end
		
		def flush
			@output.flush
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
			
			def call(*args)
				self.new.call(*args)
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
		
		def call(*args)
			@reports.each do |report|
				report.call(self, *args)
			end
		end
	end
end
