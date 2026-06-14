# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2026, by Samuel Williams.

require "bake/context"
require "covered/coverage"
require "covered/policy"

describe "covered:validate" do
	let(:context) {Bake::Context.load(File.expand_path("../..", __dir__))}
	let(:recipe) {context.lookup("covered:validate")}
	let(:validate) {recipe.instance}
	let(:file) {__FILE__}
	let(:coverage) {Covered::Coverage.new(Covered::Source.new(file), [1])}
	let(:policy) do
		Covered::Policy.new.tap do |policy|
			policy.add(coverage)
		end
	end
	
	it "prints statistics when there are no configured reports" do
		output = []
		
		mock($stderr) do |mock|
			mock.replace(:puts) do |line|
				output << line
			end
		end
		
		validate.validate(input: policy)
		
		expect(output.first).to be == "1 files checked; 1/1 lines executed; 100.0% covered."
	end
	
	it "delegates output to configured reports" do
		lines = []
		
		report = proc do |input, output|
			output.puts "custom report: #{input.to_h.count}"
		end
		
		policy.reports << report
		
		mock(STDOUT) do |mock|
			mock.replace(:puts) do |line|
				lines << line
			end
		end
		
		validate.validate(input: policy)
		
		expect(lines).to be == ["custom report: 1"]
	end
end
