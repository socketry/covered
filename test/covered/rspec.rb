# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2022-2025, by Samuel Williams.

require "covered"
require "rspec_tests"

describe "Covered::RSpec" do
	include RSpecTests

	it "can run rspec test suite with coverage" do
		input, output = IO.pipe
		
		system({"COVERAGE" => "PartialSummary"}, "rspec", "--require", spec_helper_path, test_path, out: output, err: output)
		output.close

		buffer = input.read
		expect(buffer).to be =~ /(.*?) files checked; (.*?) lines executed; (.*?)% covered/
	end
end
