# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2023-2026, by Samuel Williams.
# Copyright, 2023, by Michael Adams.

def initialize(context)
	super
	
	require_relative "../../lib/covered/config"
end

# Load the current coverage policy.
# Defaults to the default coverage path if no paths are specified.
# @parameter paths [Array(String)] The coverage database paths.
def current(paths: nil, reports: Covered::Config.reports)
	return Covered::Config.load(root: context.root, reports: reports, persist: false).policy_for(paths)
end

# Validate the coverage of multiple test runs.
# @parameter paths [Array(String)] The coverage database paths.
# @parameter minimum [Float] The minimum required coverage in order to pass.
# @parameter input [Covered::Policy] The input policy to validate.
def statistics(paths: nil, minimum: 1.0, input:)
	input ||= context.lookup("covered:policy:current").call(paths: paths)
	
	# Calculate statistics:
	statistics = Covered::Statistics.new
	
	input.each do |coverage|
		statistics << coverage
	end
	
	return statistics
end
