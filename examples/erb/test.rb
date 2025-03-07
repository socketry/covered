#!/usr/bin/env ruby
# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2023-2025, by Samuel Williams.

require "coverage"
require "erb"

Coverage.start(lines: true, eval: true)

def test(value = nil, default: "World", path: "template.erb")
	template = ERB.new(File.read(path))
	template.location = path
	
	template.result(binding)
end

# The order changes coverage, previous results are discarded.
test("Ruby")
test

puts Coverage.result
