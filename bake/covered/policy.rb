# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2023, by Samuel Williams.

def initialize(context)
	super
	
	require_relative '../../lib/covered/config'
end

# Load the current coverage policy.
def current(paths: nil)
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
	
	return policy
end
