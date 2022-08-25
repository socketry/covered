
def initialize(context)
	super
	
	require_relative '../../lib/covered'
end

# Debug the coverage of a file. Show which lines should be executable.
#
# @parameter paths [Array(String)] The paths to parse.
# @parameter execute [Boolean] Whether to execute the code.
def parse(paths: [], execute: false)
	files = output = Covered::Files.new
	output = Covered::Source.new(output)
	
	paths.each do |path|
		output.mark(path, 0, 0)
	end
	
	if execute
		capture = Covered::Capture.new(output)
		capture.enable
		paths.each do |path|
			load path
		end
		capture.disable
		
		files.paths = files.paths.slice(*paths)
	end
	
	Covered::Summary.new.call(output, $stderr)
end
