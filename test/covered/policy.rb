# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2018-2022, by Samuel Williams.

require 'covered/policy'

describe Covered::Policy do
	let(:pattern) {"**/*.rb"}
	let(:policy) {subject.new}
	
	it 'can start capture via policy' do
		expect do
			policy.start
			policy.finish
		end.not.to raise_exception
	end
	
	it 'can #include a pattern' do
		policy.include(pattern)
		
		expect(policy.output.pattern).to be == pattern
		expect(policy.output).to be_a(Covered::Include)
	end
	
	it 'can #skip a pattern' do
		policy.skip(pattern)
		
		expect(policy.output.pattern).to be == pattern
		expect(policy.output).to be_a(Covered::Skip)
	end
	
	it 'can #only a pattern' do
		policy.only(pattern)
		
		expect(policy.output.pattern).to be == pattern
		expect(policy.output).to be_a(Covered::Only)
	end
	
	it 'can specify #root' do
		policy.root(__dir__)
		
		expect(policy.output.path).to be == __dir__
		expect(policy.output).to be_a(Covered::Root)
	end
	
	it 'can select default reports' do
		policy.reports!(true)
		
		expect(policy.reports.count).to be == 1
		expect(policy.reports.first).to be_a Covered::BriefSummary
	end
	
	it 'can select specified reports' do
		policy.reports!('BriefSummary,PartialSummary')
		
		expect(policy.reports.count).to be == 2
	end
	
	it 'can #call' do
		io = StringIO.new
		
		policy.reports << Covered::BriefSummary.new
		policy.call(io)
		
		expect(io.string).to be(:include?, "* 0 files checked; 0/0 lines executed; 100.0% covered.")
	end
end
