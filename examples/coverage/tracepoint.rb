
trace_point = TracePoint.new(:call, :return, :line, :c_call, :c_return, :b_call, :b_return) do |trace|
	puts [trace.path, trace.lineno].join(":")
end

trace_point.enable

require_relative 'test'
