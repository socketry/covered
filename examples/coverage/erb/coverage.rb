# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2019-2023, by Samuel Williams.

require 'erb'
$LOAD_PATH.unshift File.expand_path('../../../lib', __dir__)

template_path = File.expand_path("template.erb", __dir__)

ENV['COVERAGE'] ||= 'PartialSummary'
require 'covered/policy/default'

$covered.start

template = ERB.new(File.read(template_path)).tap do |template|
	template.filename = template_path
end

@items = ["Cats", "Dogs", "Chickens"]
puts template.result(binding)

$covered.finish

$covered.call($stdout)
