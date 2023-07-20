# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2022-2023, by Samuel Williams.

require 'covered/files'
require 'covered/capture'

let(:code) {<<~RUBY}
output = String.new
begin
	output << "
".freeze; end
RUBY

it "can parse multi-line methods" do
	files = Covered::Files.new
	
	source = Covered::Source.for(__FILE__, code: code, line_offset: 10)
	
	capture = Covered::Capture.new(files)
	capture.execute(source)
	
	coverage = files[__FILE__]
	expect(coverage.counts).not.to be(:include?, 0)
end
