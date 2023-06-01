#!/usr/bin/env ruby
# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2019-2023, by Samuel Williams.

$LOAD_PATH.unshift File.expand_path('../../../lib', __dir__)

require 'erb'
require 'covered/config'

template_path = File.expand_path("template.erb", __dir__)

covered = Covered::Config.load(coverage: 'FullSummary')
covered.start

template = ERB.new(File.read(template_path)).tap do |template|
	template.filename = template_path
end

@items = ["Cats", "Dogs", "Chickens"]

template.result(binding)

covered.finish
covered.call($stdout)

covered.each do |coverage|
	puts "Coverage counts (values): #{coverage.counts.inspect}"
	puts "Coverage counts (size): #{coverage.counts.size}"
	puts "File lines (size): #{coverage.read.lines.size}"
end
