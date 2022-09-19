# Copyright, 2018, by Samuel G. D. Williams. <http://www.codeotaku.com>
# 
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
# 
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.

require 'covered/policy'

describe Covered::Policy do
	let(:pattern) {"**/*.rb"}
	let(:policy) {subject.new}
	
	it 'can enable capture via policy' do
		expect do
			policy.enable
			policy.disable
		end.not.to raise_exception
	end
	
	it 'can specify #source mapping' do
		policy.source
		
		expect(policy.source).to be_a(Covered::Source)
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
