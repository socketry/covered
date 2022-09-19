# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2019-2022, by Samuel Williams.

trace_point = TracePoint.new(:call, :return, :line, :c_call, :c_return, :b_call, :b_return) do |trace|
	puts [trace.path, trace.lineno].join(":")
end

trace_point.enable

require_relative 'test'
