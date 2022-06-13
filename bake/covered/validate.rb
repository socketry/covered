
def initialize(context)
	super
	
	require_relative '../../lib/covered/policy/default'
end

# Validate the coverage of multiple test runs.
# @parameter paths [Array(String)] The coverage database paths.
# @parameter minumum [Float] The minimum required coverage in order to pass.
def validate(paths: nil, minimum: 1.0)
	paths&.each do |path|
		Covered::Persist.new($covered.output, path).load!
	end
	
	$covered.flush
	
	statistics = Covered::Statistics.new
		
	$covered.each do |coverage|
		statistics << coverage
	end
	
	statistics.validate!(minimum)
end
