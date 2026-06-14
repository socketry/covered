# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2018-2025, by Samuel Williams.

require "covered/partial_summary"
require "covered/files"

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
	
	it "shows 100% coverage files when there are partial files" do
		# Create a scenario with mixed coverage
		partial_file = __FILE__
		complete_file = File.join(__dir__, "../covered/summary.rb")
		
		# Mark partial coverage for this file
		files.mark(partial_file, 1, 1)
		files.mark(partial_file, 2, 0)  # uncovered line
		
		# Mark complete coverage for summary.rb
		files.mark(complete_file, 1, 1)
		files.mark(complete_file, 2, 1)
		
		summary.call(files, io)
		
		# Should show the message about 100% coverage files
		expect(io.string).to be(:include?, "100% coverage and is not shown above:")
		expect(io.string).to be(:include?, "summary.rb")
	end
	
	it "shows multiple 100% coverage files when there are partial files" do
		partial_file = __FILE__
		complete_file1 = File.join(__dir__, "../covered/summary.rb")
		complete_file2 = File.join(__dir__, "../covered/brief_summary.rb")
		
		files.mark(partial_file, 1, 1)
		files.mark(partial_file, 2, 0)
		
		files.mark(complete_file1, 1, 1)
		files.mark(complete_file2, 1, 1)
		
		summary.call(files, io)
		
		expect(io.string).to be(:include?, "2 files have 100% coverage and are not shown above:")
		expect(io.string).to be(:include?, "summary.rb")
		expect(io.string).to be(:include?, "brief_summary.rb")
	end
	
	it "prints rendering errors" do
		coverage = Covered::Coverage.new(Covered::Source.new("missing.rb"), [nil, 1, 0])
		files.add(coverage)
		
		summary.call(files, io)
		
		expect(io.string).to be(:include?, "Error: No such file or directory")
	end
	
	it "does not show 100% coverage files when all files are 100%" do
		# Create a scenario where all files have 100% coverage
		file1 = __FILE__
		file2 = File.join(__dir__, "../covered/summary.rb")
		
		# Mark complete coverage for both files
		files.mark(file1, 1, 1)
		files.mark(file1, 2, 1)
		files.mark(file2, 1, 1)
		files.mark(file2, 2, 1)
		
		summary.call(files, io)
		
		# Should NOT show the message about 100% coverage files (would be redundant)
		expect(io.string).not.to be(:include?, "100% coverage and is not shown above:")
	end
end
