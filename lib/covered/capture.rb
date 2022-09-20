# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2018-2022, by Samuel Williams.

require_relative 'wrapper'

require 'coverage'

module Covered
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
	
	# class Capture < Wrapper
	# 	def enable
	# 		super
	# 
	# 		::Coverage.start
	# 	end
	# 
	# 	def disable
	# 		result = ::Coverage.result
	# 
	# 		puts result.inspect
	# 
	# 		result.each do |path, lines|
	# 			lines.each_with_index do |lineno, count|
	# 				@output.mark(path, lineno, count)
	# 			end
	# 		end
	# 
	# 		super
	# 	end
	# end
end
