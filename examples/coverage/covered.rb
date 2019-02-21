
ENV['COVERAGE'] ||= 'PartialSummary'
require 'covered/policy/default'

$covered.enable

require_relative 'test'

$covered.disable

$covered.call($stdout)
