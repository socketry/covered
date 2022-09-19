# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2018-2022, by Samuel Williams.

require 'covered/summary'
require 'covered/files'

describe Covered::Summary do
	let(:files) {Covered::Files.new}
	let(:summary) {Covered::Summary.new}
	
	let(:first_line) {File.readlines(__FILE__).first}
	let(:io) {StringIO.new}
	
	it "can generate source code listing" do
		files.mark(__FILE__, 24, 1)
		files.mark(__FILE__, 25, 0)
		
		summary.call(files, io)
		
		expect(io.string).to be(:include?, "RSpec.describe Covered::Summary do")
	end
end
