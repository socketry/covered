# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2019-2025, by Samuel Williams.

require "covered/policy"

describe Covered::Policy::Autoload do
	with "PartialSummary class" do
		let(:autoload) {subject.new("PartialSummary")}
		
		it "should autoload and instantiate class" do
			expect(autoload.new).to be_a Covered::PartialSummary
		end
	end
	
	with "unknown class" do
		let(:autoload) {subject.new("Unknown")}
		
		it "fails to autoload unknown class" do
			expect do
				autoload.new
			end.to raise_exception(LoadError)
		end
	end
end
