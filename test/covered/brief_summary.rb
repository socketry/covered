# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2018-2025, by Samuel Williams.

require "covered/summary"
require "covered/files"

describe Covered::BriefSummary do
	let(:files) {Covered::Files.new}
	let(:summary) {subject.new}
	
	let(:first_line) {File.readlines(__FILE__).first}
	let(:io) {StringIO.new}
	
	it "can generate partial summary" do
		files.mark(__FILE__, 37, 1)
		files.mark(__FILE__, 38, 0)
		
		summary.call(files, io)
		
		expect(io.string).not.to be =~ /#{first_line}/
		expect(io.string).to be =~ /#{__FILE__}/
	end
end
