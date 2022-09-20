# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2022, by Samuel Williams.

require 'covered/files'
require 'covered/source'
require 'covered/capture'

let(:code) {<<~RUBY}
output = String.new
begin
	output << "
".freeze; end
RUBY

it "can parse multi-line methods" do
	files = Covered::Files.new
	source = Covered::Source.new(files)
	
	coverage = source.add(Covered::Coverage.source("test.rb", code))
	
	capture = Covered::Capture.new(files)
	capture.execute(coverage.source)
	
	expect(coverage.counts).not.to be(:include?, 0)
end
