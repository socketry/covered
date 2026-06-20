# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2026, by Samuel Williams.

require "covered"
require "covered/config"

describe "Coverage::Autostart" do
	let(:script_path) {File.expand_path("../../fixtures/autostart/report.rb", __dir__)}
	
	it "reports at exit when reports are enabled" do
		input, output = IO.pipe
		
		system({"COVERAGE" => "PartialSummary"}, "ruby", "-rcovered/autostart", script_path, out: output, err: output)
		output.close
		
		buffer = input.read
		expect(buffer).to be(:include?, "autostart fixture")
		expect(buffer).to be =~ /(.*?) files checked; (.*?) lines executed; (.*?)% covered/
	end
	
	it "starts coverage and reports at exit" do
		events = []
		exit_hook = nil
		
		config = Object.new
		config.define_singleton_method(:start){events << :start}
		config.define_singleton_method(:finish){events << :finish}
		config.define_singleton_method(:report?){true}
		config.define_singleton_method(:call){|stream| events << [:call, stream]}
		
		Object.const_set(:Coverage, Module.new) unless Object.const_defined?(:Coverage)
		::Coverage.const_set(:Autostart, Module.new) unless ::Coverage.const_defined?(:Autostart)
		
		::Coverage::Autostart.define_singleton_method(:at_exit) do |&block|
			exit_hook = block
		end
		
		mock(Covered::Config) do |mock|
			mock.replace(:load){config}
		end
		
		load File.expand_path("../../lib/covered/autostart.rb", __dir__)
		
		exit_hook.call
		
		expect(events).to be == [
			:start,
			:finish,
			[:call, $stderr],
		]
	end
end
