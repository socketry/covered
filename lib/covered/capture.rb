# Copyright, 2018, by Samuel G. D. Williams. <http://www.codeotaku.com>
# 
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
# 
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.

require 'rainbow'

module Covered
	class Capture
		def initialize(output)
			@paths = {}
			
			@line_trace = TracePoint.new(:line) do |trace_point|
				if path = trace_point.path
					# if path =~ /\.xnode$/
					# 	binding.pry
					# end
					# 
					output.mark(path, trace_point.lineno)
				end
			end
			# 
			# @call_trace = TracePoint.new(:c_call) do |trace_point|
			# 	if trace_point.method_id == :eval
			# 	end
			# end
		end
		
		attr :paths
		
		def enable
			# @call_trace.enable
			@line_trace.enable
		end
		
		def disable
			@line_trace.disable
			# @call_trace.disable
		end
	end
end
