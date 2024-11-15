# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2022-2024, by Samuel Williams.

require 'covered'
require 'minitest_tests'

describe "Covered::Minitest" do
	include MinitestTests
	
	it "can run minitest test suite with coverage" do
		input, output = IO.pipe

		env = {
			"COVERAGE" => "PartialSummary",
			"MINIMUM_COVERAGE" => "100.1"
		}

		system(env, test_path, out: output, err: output)
		output.close

		expect($?.exitstatus).not.to be(:zero?)

		buffer = input.read

		expect(buffer).to be =~ /(.*?) files checked; (.*?) lines executed; (.*?)% covered/
		expect(buffer).to be =~ /is less than required minimum of 100.1/
	end
end
