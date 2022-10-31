# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2022, by Samuel Williams.

require 'covered/files'
require 'covered/source'
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
	source = Covered::Source.new(files)
	
	coverage = source.add(Covered::Coverage.source("test.rb", code))
	
	capture = Covered::Capture.new(files)
	capture.execute(coverage.source)
	
	expect(coverage.counts).not.to be(:include?, 0)
end
