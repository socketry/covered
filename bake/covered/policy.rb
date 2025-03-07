# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2023-2025, by Samuel Williams.
# Copyright, 2023, by Michael Adams.

def initialize(context)
	super
	
	require_relative "../../lib/covered/config"
end

# Load the current coverage policy.
# Defaults to the default coverage path if no paths are specified.
# @parameter paths [Array(String)] The coverage database paths.
def current(paths: nil, reports: Covered::Config.reports)
	policy = Covered::Policy.new
	
	# Load the default path if no paths are specified:
	paths ||= Dir.glob(Covered::Persist::DEFAULT_PATH, base: context.root)
	
	# If no paths are specified, raise an error:
	if paths.empty?
		raise ArgumentError, "No coverage paths specified!"
	end
	
	# Load all coverage information:
	paths.each do |path|
		# It would be nice to have a better algorithm here than just ignoring mtime - perhaps using checksums?
		Covered::Persist.new(policy.output, path).load!(ignore_mtime: true)
	end
	
	if reports
		policy.reports!(reports)
	end
	
	return policy
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
