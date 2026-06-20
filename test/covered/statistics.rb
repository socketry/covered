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
		let(:other_coverage) {Covered::Coverage.new(Covered::Source.new("bar.rb"), [nil, 1])}
		
		it "adds new paths to cached totals" do
			statistics << partial_coverage
			
			total = statistics.total
			
			statistics << other_coverage
			
			expect(statistics.total).to be_equal(total)
			expect(statistics.count).to be == 2
			expect(statistics.executable_count).to be == 3
			expect(statistics.executed_count).to be == 2
		end
		
		it "invalidates cached totals" do
			statistics << partial_coverage
			
			total = statistics.total
			
			expect(statistics.count).to be == 1
			expect(statistics.executable_count).to be == 2
			expect(statistics.executed_count).to be == 1
			expect(statistics.total).to be_equal(total)
			
			statistics << complete_coverage
			
			expect(statistics.total).not.to be_equal(total)
			expect(statistics.count).to be == 1
			expect(statistics.executable_count).to be == 2
			expect(statistics.executed_count).to be == 2
		end
	end
	
	with "after adding coverage" do
		let(:coverage) {Covered::Coverage.new(source, [nil, 1])}
		
		it "does not share mutable state with the original coverage" do
			statistics << coverage
			
			coverage.mark(2, 1)
			coverage.path = "bar.rb"
			
			expect(statistics.count).to be == 1
			expect(statistics["foo.rb"].counts).to be == [nil, 1]
			expect(statistics.executable_count).to be == 1
			expect(statistics.executed_count).to be == 1
		end
	end
end

describe Covered::Statistics::Aggregate do
	let(:source) {Covered::Source.new("foo.rb")}
	let(:other_source) {Covered::Source.new("bar.rb")}
	
	with "multiple coverage objects" do
		let(:complete_coverage) {Covered::Coverage.new(source, [nil, 1, 1])}
		let(:other_coverage) {Covered::Coverage.new(other_source, [nil, 0])}
		let(:aggregate) {subject.for([complete_coverage, other_coverage])}
		
		it "summarizes coverage" do
			expect(aggregate.count).to be == 2
			expect(aggregate.executable_count).to be == 3
			expect(aggregate.executed_count).to be == 2
		end
	end
	
	with "an aggregate" do
		let(:coverage) {Covered::Coverage.new(source, [nil, 1])}
		let(:aggregate) {subject.for([coverage])}
		
		it "can add coverage" do
			aggregate << Covered::Coverage.new(other_source, [nil, 0])
			
			expect(aggregate.count).to be == 2
			expect(aggregate.executable_count).to be == 2
			expect(aggregate.executed_count).to be == 1
		end
	end
end
