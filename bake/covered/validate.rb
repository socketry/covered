# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2022-2023, by Samuel Williams.

def initialize(context)
	super
	
	require_relative '../../lib/covered/config'
end

# Validate the coverage of multiple test runs.
# @parameter paths [Array(String)] The coverage database paths.
# @parameter minimum [Float] The minimum required coverage in order to pass.
def validate(paths: nil, minimum: 1.0)
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
	
	# Calculate statistics:
	statistics = Covered::Statistics.new
	
	policy.each do |coverage|
		statistics << coverage
	end
	
	# Print statistics:
	statistics.print($stderr)
	
	# Validate statistics and raise an error if they are not met:
	statistics.validate!(minimum)
end
