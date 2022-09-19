# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2018-2022, by Samuel Williams.

require 'covered/statistics'

describe Covered::Statistics do
	let(:statistics) {subject.new}
	
	with 'initial state' do
		it "is zero" do
			expect(statistics.count).to be == 0
			expect(statistics.executable_count).to be == 0
			expect(statistics.executed_count).to be == 0
		end
		
		it "is complete" do
			expect(statistics).to be(:complete?)
		end
	end
	
	with 'after adding full coverage' do
		let(:coverage) {Covered::Coverage.new("foo.rb", [nil, 1])}
		
		def before
			statistics << coverage
			super
		end
		
		it "has one entry" do
			expect(statistics.count).to be == 1
			expect(statistics.executable_count).to be == 1
			expect(statistics.executed_count).to be == 1
		end
		
		it "is complete" do
			expect(statistics).to be(:complete?)
		end
	end
	
	with 'after adding partial coverage' do
		let(:coverage) {Covered::Coverage.new("foo.rb", [nil, 1, 0])}
		
		def before
			statistics << coverage
			super
		end
		
		it "has one entry" do
			expect(statistics.count).to be == 1
			expect(statistics.executable_count).to be == 2
			expect(statistics.executed_count).to be == 1
		end
		
		it "is not complete" do
			expect(statistics).not.to be(:complete?)
		end
	end
end
