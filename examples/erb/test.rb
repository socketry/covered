#!/usr/bin/env ruby

require 'coverage'
require 'erb'

Coverage.start(lines: true, eval: true)

def test(value = nil, default: "World", path: 'template.erb')
	template = ERB.new(File.read(path))
	template.location = path
	
	template.result(binding)
end

# The order changes coverage, previous results are discarded.
test("World")
test

puts Coverage.result