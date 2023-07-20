# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2022, by Samuel Williams.

require 'covered'
require 'minitest_tests'

describe "Covered::Minitest" do
	include MinitestTests
	
	it "can run minitest test suite with coverage" do
		input, output = IO.pipe
		
		system({"COVERAGE" => "PartialSummary"}, test_path, out: output, err: output)
		output.close

		buffer = input.read
		expect(buffer).to be =~ /(.*?) files checked; (.*?) lines executed; (.*?)% covered/
	end
end
