
def initialize(context)
	super
	
	require_relative '../../lib/covered/config'
end

# Validate the coverage of multiple test runs.
# @parameter paths [Array(String)] The coverage database paths.
# @parameter minumum [Float] The minimum required coverage in order to pass.
def validate(paths: nil, minimum: 1.0)
	config = Covered::Config.load
	
	paths&.each do |path|
		# It would be nice to have a better algorithm here than just ignoring mtime - perhaps using checksums?
		Covered::Persist.new(config.output, path).load!(ignore_mtime: true)
	end
	
	config.flush
	
	statistics = Covered::Statistics.new
	
	config.each do |coverage|
		statistics << coverage
	end
	
	statistics.print($stderr)
	
	statistics.validate!(minimum)
end
