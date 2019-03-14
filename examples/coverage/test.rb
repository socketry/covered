trace_point = TracePoint.new(:call, :return, :line, :c_call, :c_return, :b_call, :b_return) do |trace|
	puts [trace.path, trace.lineno].join(":")
end

trace_point.enable

values = {foo: 10}

def shell_escape(x)
	x
end

values.map{|key, value| [
	key.to_s.upcase,
	shell_escape(value) # TracePoint is never triggered for this line.
]}
