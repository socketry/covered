# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2022, by Samuel Williams.

require 'covered/files'
require 'covered/capture'
require 'covered/summary'

let(:code) {<<~RUBY}
begin
	raise "Hello"
rescue ArgumentError => error
rescue RuntimeError => error
	x = 20
	y = 30
end
RUBY

it "can parse multi-line methods" do
	files = Covered::Files.new
	
	source = Covered::Source.for(__FILE__, code, 11)
	
	capture = Covered::Capture.new(files)
	capture.execute(source)
	
	coverage = files[__FILE__]
	expect(coverage.counts).not.to be(:include?, 0)
	
	# Show the actual coverage:
	# Covered::Summary.new(threshold: nil).call(files, $stderr)
end
