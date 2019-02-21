

trace_point = TracePoint.new(:call, :line) do |trace|
	puts [trace.path, trace.lineno].join(":")
end

trace_point.enable

require_relative 'test'
