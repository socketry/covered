# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2018-2025, by Samuel Williams.

require "covered/coverage"

describe Covered::Coverage do
	let(:source) {Covered::Source.new("foo.rb")}
	let(:coverage) {subject.new(source, [nil, 1], 1 => ["covered"])}
	
	it "can be duplicated" do
		copy = coverage.dup
		
		expect(copy.equal?(coverage)).to be == false
		expect(copy.source.equal?(coverage.source)).to be == false
		expect(copy.counts).to be == coverage.counts
		expect(copy.counts.equal?(coverage.counts)).to be == false
		expect(copy.annotations).to be == coverage.annotations
		expect(copy.annotations.equal?(coverage.annotations)).to be == false
		expect(copy.annotations[1].equal?(coverage.annotations[1])).to be == false
	end
	
	it "does not share mutable state with duplicates" do
		copy = coverage.dup
		
		copy.mark(2, 1)
		copy.annotate(1, "copy")
		copy.path = "copy.rb"
		
		expect(coverage.path).to be == "foo.rb"
		expect(coverage.counts).to be == [nil, 1]
		expect(coverage.annotations).to be == {1 => ["covered"]}
	end
end
