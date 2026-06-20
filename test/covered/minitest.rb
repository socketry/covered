# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2022-2025, by Samuel Williams.

require "covered"
require "minitest_tests"
require "covered/minitest"

describe "Covered::Minitest" do
	include MinitestTests
	
	it "can run minitest test suite with coverage" do
		input, output = IO.pipe
		
		system({"COVERAGE" => "PartialSummary"}, test_path, out: output, err: output)
		output.close
		
		buffer = input.read
		expect(buffer).to be =~ /(.*?) files checked; (.*?) lines executed; (.*?)% covered/
		expect(buffer).to be(:include?, "1 runs, 1 assertions, 0 failures, 0 errors, 0 skips")
	end
	
	it "starts coverage before running minitest" do
		events = []
		coverage = Object.new
		coverage.define_singleton_method(:start){events << :start}
		
		runner = Class.new do
			prepend Covered::Minitest
			
			def run
				:ran
			end
		end.new
		
		original_coverage = $covered
		$covered = coverage
		
		expect(runner.run).to be == :ran
		expect(events).to be == [:start]
	ensure
		$covered = original_coverage
	end
	
	it "registers the Minitest hooks when coverage is enabled" do
		events = []
		
		coverage = Object.new
		coverage.define_singleton_method(:record?){true}
		coverage.define_singleton_method(:finish){events << :finish}
		coverage.define_singleton_method(:call){|stream| events << [:call, stream]}
		
		original_coverage = $covered
		original_after_run = Minitest.method(:after_run)
		
		mock(Covered::Config) do |mock|
			mock.replace(:load){coverage}
		end
		
		mock(Minitest.singleton_class) do |mock|
			mock.replace(:prepend) do |mod|
				events << [:prepend, mod]
			end
		end
		
		Minitest.define_singleton_method(:after_run) do |&block|
			events << :after_run
			block.call
		end
		
		events.clear
		
		load File.expand_path("../../lib/covered/minitest.rb", __dir__)
		
		expect(events).to be == [
			[:prepend, Covered::Minitest],
			:after_run,
			:finish,
			[:call, $stderr],
		]
	ensure
		$covered = original_coverage
		Minitest.define_singleton_method(:after_run, original_after_run) if original_after_run
	end
end
