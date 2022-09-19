# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2019-2022, by Samuel Williams.

require 'covered/coverage'
require 'covered/persist'
require 'wrapper_examples'

describe Covered::Persist do
	it_behaves_like WrapperExamples
	
	let(:coverage) {Covered::Coverage.new(__FILE__)}
	let(:output) {Covered::Base.new}
	let(:persist) {subject.new(output)}
	let(:record) {persist.serialize(coverage)}
	
	it "can serialize coverage" do
		expect(record[:path]).to be == __FILE__
	end
end
