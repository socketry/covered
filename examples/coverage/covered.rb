# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2019-2025, by Samuel Williams.

ENV["COVERAGE"] ||= "PartialSummary"
require "covered/policy/default"

$covered.start

require_relative "test"

$covered.finish

$covered.call($stdout)
