# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2018-2025, by Samuel Williams.

require "covered/statistics"

describe Covered::Statistics do
	let(:statistics) {subject.new}
	let(:source) {Covered::Source.new("foo.rb")}
	
	with "initial state" do
		it "is zero" do
			expect(statistics.count).to be == 0
			expect(statistics.executable_count).to be == 0
			expect(statistics.executed_count).to be == 0
		end
		
		it "is complete" do
			expect(statistics).to be(:complete?)
		end
	end
	
	with "after adding full coverage" do
		let(:coverage) {Covered::Coverage.new(source, [nil, 1])}
		
		def before
			statistics << coverage
			super
		end
		
		it "has one entry" do
			expect(statistics.count).to be == 1
			expect(statistics.executable_count).to be == 1
			expect(statistics.executed_count).to be == 1
		end
		
		it "is complete" do
			expect(statistics).to be(:complete?)
		end
	end
	
	with "after adding partial coverage" do
		let(:coverage) {Covered::Coverage.new(source, [nil, 1, 0])}
		
		def before
			statistics << coverage
			super
		end
		
		it "has one entry" do
			expect(statistics.count).to be == 1
			expect(statistics.executable_count).to be == 2
			expect(statistics.executed_count).to be == 1
		end
		
		it "is not complete" do
			expect(statistics).not.to be(:complete?)
		end
	end
	
	with "after adding overlapping coverage" do
		let(:complete_coverage) {Covered::Coverage.new(source, [nil, 1, 1])}
		let(:partial_coverage) {Covered::Coverage.new(source, [nil, 1, 0])}
		
		def before
			statistics << complete_coverage
			statistics << partial_coverage
			super
		end
		
		it "merges coverage for the same path" do
			expect(statistics.count).to be == 1
			expect(statistics.executable_count).to be == 2
			expect(statistics.executed_count).to be == 2
		end
		
		it "is complete" do
			expect(statistics).to be(:complete?)
		end
	end
	
	with "after reading total before adding coverage" do
		let(:partial_coverage) {Covered::Coverage.new(source, [nil, 1, 0])}
		let(:complete_coverage) {Covered::Coverage.new(source, [nil, 0, 1])}
		
		def before
			statistics << partial_coverage
			statistics.total
			statistics << complete_coverage
			super
		end
		
		it "invalidates cached totals" do
			expect(statistics.count).to be == 1
			expect(statistics.executable_count).to be == 2
			expect(statistics.executed_count).to be == 1
		end
	end
end

describe Covered::Statistics::Aggregate do
	let(:source) {Covered::Source.new("foo.rb")}
	let(:other_source) {Covered::Source.new("bar.rb")}
	
	with "multiple coverage objects" do
		let(:complete_coverage) {Covered::Coverage.new(source, [nil, 1, 1])}
		let(:partial_coverage) {Covered::Coverage.new(source, [nil, 1, 0])}
		let(:other_coverage) {Covered::Coverage.new(other_source, [nil, 0])}
		let(:aggregate) {subject.new([complete_coverage, partial_coverage, other_coverage])}
		
		it "merges coverage for the same path" do
			expect(aggregate.count).to be == 2
			expect(aggregate.executable_count).to be == 3
			expect(aggregate.executed_count).to be == 2
		end
	end
	
	with "an existing aggregate" do
		let(:coverage) {Covered::Coverage.new(source, [nil, 1])}
		let(:aggregate) {subject.new([coverage])}
		
		it "is immutable" do
			expect(aggregate).to be(:frozen?)
		end
	end
end
