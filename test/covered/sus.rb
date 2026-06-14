# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2026, by Samuel Williams.

require "covered/sus"

describe Covered::Sus do
	let(:coverage) do
		Class.new do
			attr :events
			
			def initialize(record: true)
				@record = record
				@events = []
			end
			
			def record?
				@record
			end
			
			def start
				@events << :start
			end
			
			def finish
				@events << :finish
			end
			
			def call(output)
				output << "covered"
				@events << :call
			end
		end
	end
	
	let(:runner_class) do
		base = Class.new do
			def initialize
			end
			
			def after_tests(assertions)
			end
		end
		
		Class.new(base) do
			include Covered::Sus
			
			attr :events
			
			def initialize
				@events = []
				super
			end
			
			def root
				__dir__
			end
			
			def output
				Struct.new(:io).new(StringIO.new)
			end
			
			def after_tests(assertions)
				@events << [:after_tests, assertions]
				super
			end
		end
	end
	
	it "starts and finishes configured coverage" do
		config = coverage.new
		
		mock(Covered::Config) do |mock|
			mock.replace(:load) do |root:|
				expect(root).to be == __dir__
				config
			end
		end
		
		mock(ENV) do |mock|
			mock.replace(:[]) do |key|
				"PartialSummary" if key == "COVERAGE"
			end
		end
		
		runner = runner_class.new
		runner.after_tests(:assertions)
		
		expect(runner.covered).to be == config
		expect(config.events).to be == [:start, :finish, :call]
		expect(runner.events).to be == [[:after_tests, :assertions]]
	end
	
	it "skips coverage when it is not configured to record" do
		config = coverage.new(record: false)
		
		mock(Covered::Config) do |mock|
			mock.replace(:load) do |root:|
				config
			end
		end
		
		mock(ENV) do |mock|
			mock.replace(:[]) do |key|
				"Quiet" if key == "COVERAGE"
			end
		end
		
		runner = runner_class.new
		runner.after_tests(:assertions)
		
		expect(runner.covered).to be == config
		expect(config.events).to be(:empty?)
	end
	
	it "does nothing when coverage is not requested" do
		mock(ENV) do |mock|
			mock.replace(:[]) do |key|
				nil
			end
		end
		
		runner = runner_class.new
		runner.after_tests(:assertions)
		
		expect(runner.covered).to be_nil
	end
end
