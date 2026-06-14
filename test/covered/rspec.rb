# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2022-2025, by Samuel Williams.

require "covered"
require "rspec_tests"
require "rspec/core"
require "covered/rspec"

describe "Covered::RSpec" do
	include RSpecTests
	
	it "can run rspec test suite with coverage" do
		input, output = IO.pipe
		
		system({"COVERAGE" => "PartialSummary"}, "rspec", "--require", spec_helper_path, test_path, out: output, err: output)
		output.close
		
		buffer = input.read
		expect(buffer).to be =~ /(.*?) files checked; (.*?) lines executed; (.*?)% covered/
		expect(buffer).to be(:include?, "1 example, 0 failures")
	end
	
	it "starts coverage before loading spec files" do
		events = []
		coverage = Object.new
		coverage.define_singleton_method(:start){events << :start}
		
		configuration = Class.new do
			prepend Covered::RSpec::Policy
			
			def load_spec_files
				:loaded
			end
		end.new
		
		original_coverage = $covered
		$covered = coverage
		
		expect(configuration.load_spec_files).to be == :loaded
		expect(events).to be == [:start]
	ensure
		$covered = original_coverage
	end
	
	it "gets and sets the active coverage" do
		configuration = Object.new
		configuration.singleton_class.prepend(Covered::RSpec::Policy)
		
		original_coverage = $covered
		coverage = Object.new
		
		configuration.covered = coverage
		
		expect(configuration.covered).to be == coverage
	ensure
		$covered = original_coverage
	end
	
	it "registers the RSpec hooks when coverage is enabled" do
		events = []
		output = StringIO.new
		
		coverage = Object.new
		coverage.define_singleton_method(:record?){true}
		coverage.define_singleton_method(:finish){events << :finish}
		coverage.define_singleton_method(:call){|stream| events << [:call, stream]}
		
		config = Object.new
		config.define_singleton_method(:after) do |name, &block|
			events << [:after, name]
			block.call
		end
		config.define_singleton_method(:output_stream){output}
		
		original_coverage = $covered
		
		mock(Covered::Config) do |mock|
			mock.replace(:load){coverage}
		end
		
		mock(RSpec::Core::Configuration) do |mock|
			mock.replace(:prepend) do |mod|
				events << [:prepend, mod]
			end
		end
		
		mock(RSpec) do |mock|
			mock.replace(:configure) do |&block|
				events << :configure
				block.call(config)
			end
		end
		
		load File.expand_path("../../lib/covered/rspec.rb", __dir__)
		
		expect(events).to be == [
			[:prepend, Covered::RSpec::Policy],
			:configure,
			[:after, :suite],
			:finish,
			[:call, output],
		]
	ensure
		$covered = original_coverage
	end
end
