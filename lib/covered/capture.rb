# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2018-2022, by Samuel Williams.

require_relative 'wrapper'

require 'coverage'

module Covered
	def self.coverage_with_eval?
		if ::Coverage.respond_to?(:supported?)
			::Coverage.supported?(:eval)
		end
	end
	
	unless self.coverage_with_eval?
		class Capture < Wrapper
			def initialize(output)
				super(output)
				
				begin
					@trace = TracePoint.new(:line, :call, :c_call) do |trace|
						if trace.event == :call
							# Ruby doesn't always mark call-sites in sub-expressions, so we use this approach to compute a call site and mark it:
							if location = caller_locations(2, 1).first and path = location.path
								@output.mark(path, location.lineno, 1)
							end
						end
						
						if path = trace.path
							@output.mark(path, trace.lineno, 1)
						end
					end
				rescue
					warn "Line coverage disabled: #{$!}"
					@trace = nil
				end
			end
			
			def enable
				super
				
				@trace&.enable
			end
			
			def disable
				@trace&.disable
				
				super
			end
			
			def execute(source, binding: TOPLEVEL_BINDING)
				enable
				
				eval(source.code!, binding, source.path)
			ensure
				disable
			end
		end
	else
		class Capture < Wrapper
			def enable
				super
				
				::Coverage.start(lines: true, eval: true)
			end
			
			def disable
				results = ::Coverage.result

				results.each do |path, result|
					lines = result[:lines]

					lines.each_with_index do |count, lineno|
						@output.mark(path, lineno+1, count) if count
					end
				end
		
				super
			end

			def execute(source, binding: TOPLEVEL_BINDING)
				enable
				
				eval(source.code!, binding, source.path)
			ensure
				disable
			end
		end
	end
end
