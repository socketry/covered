# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2022-2025, by Samuel Williams.

def initialize(context)
	super
	
	require_relative "../../lib/covered"
end

# Debug the coverage of a file. Show which lines should be executable.
#
# @parameter paths [Array(String)] The paths to parse.
# @parameter execute [Boolean] Whether to execute the code.
def parse(paths: [], execute: false)
	files = output = Covered::Files.new
	
	paths.each do |path|
		output.mark(path, 0, 0)
	end
	
	if execute
		capture = Covered::Capture.new(output)
		capture.start
		paths.each do |path|
			load path
		end
		capture.finish
		
		files.paths = files.paths.slice(*paths)
	end
	
	Covered::Summary.new.call(output, $stderr)
end
