# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2022-2025, by Samuel Williams.

def initialize(context)
	super
	
	require_relative "../../lib/covered/config"
end

# Validate the coverage of multiple test runs.
# @parameter paths [Array(String)] The coverage database paths.
# @parameter minimum [Float] The minimum required coverage in order to pass.
# @parameter input [Covered::Policy] The input policy to validate.
def validate(paths: nil, minimum: 1.0, input:)
	policy ||= context.lookup("covered:policy:current").call(paths: paths)
	
	# Calculate statistics:
	statistics = Covered::Statistics.new
	
	policy.each do |coverage|
		statistics << coverage
	end
	
	# Print statistics:
	statistics.print($stderr)
	
	policy.call(STDOUT)
	
	# Validate statistics and raise an error if they are not met:
	statistics.validate!(minimum)
end
