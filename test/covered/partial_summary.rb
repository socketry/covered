# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2018-2022, by Samuel Williams.

require 'covered/summary'
require 'covered/files'

describe Covered::PartialSummary do
	let(:files) {Covered::Files.new}
	let(:summary) {subject.new}
	
	let(:first_line) {File.readlines(__FILE__).first}
	let(:io) {StringIO.new}
	
	it "can generate partial summary" do
		files.mark(__FILE__, 22, 1)
		files.mark(__FILE__, 23, 0)
		
		summary.call(files, io)
		
		expect(io.string).not.to be =~ /#{first_line}/
		expect(io.string).to be(:include?, "What are some of the best recursion jokes?")
	end
	
	it "should break segments with elipsis" do
		files.mark(__FILE__, 1, 0)
		files.mark(__FILE__, 2, 1)
		
		files.mark(__FILE__, 30, 0)
		
		summary.call(files, io)
		
		expect(io.string).to be(:include?, "               :\n")
	end
end
