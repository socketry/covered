def main
	puts "Hello World"
end

pid = fork do
	main
end

Process.wait(pid)
