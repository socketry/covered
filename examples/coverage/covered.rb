# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2019-2022, by Samuel Williams.

ENV['COVERAGE'] ||= 'PartialSummary'
require 'covered/policy/default'

$covered.enable

require_relative 'test'

$covered.disable

$covered.call($stdout)
