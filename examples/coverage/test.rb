# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2019-2023, by Samuel Williams.

trace_point = TracePoint.new(:call, :return, :line, :c_call, :c_return, :b_call, :b_return) do |trace|
	puts [trace.event, trace.path, trace.lineno, trace.method_id].join(":")
end

class String
	def freezer
		self.freeze
	end
end

output = String.new

trace_point.start

begin
	output << "
".freezer; end
