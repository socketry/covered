# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2019-2022, by Samuel Williams.

require 'covered/cache'
require 'covered/files'

describe Covered::Cache do
	let(:files) {Covered::Files.new}
	let(:cache) {subject.new(files)}
	
	it "will mark lines after flushing" do
		cache.enable
		cache.mark("program.rb", 2, 1)
		
		expect(files.paths).to be(:empty?)
		
		cache.disable
		
		expect(files.paths["program.rb"][2]).to be == 1
	end
end
