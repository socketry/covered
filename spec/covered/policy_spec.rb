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

RSpec.describe Covered::Policy do
	let(:pattern) {"**/*.rb"}
	
	it 'can generate policy' do
		policy = Covered.policy do
		end
		
		expect(policy).to be_frozen
		expect(policy).to be_kind_of described_class
	end
	
	it 'can enable capture via policy' do
		expect do
			subject.enable
			subject.disable
		end.to_not raise_error
	end
	
	it 'can specify #source mapping' do
		subject.source
		
		expect(subject.source).to be_kind_of(Covered::Source)
	end
	
	it 'can #include a pattern' do
		subject.include(pattern)
		
		expect(subject.output.pattern).to be == pattern
		expect(subject.output).to be_kind_of(Covered::Include)
	end
	
	it 'can #skip a pattern' do
		subject.skip(pattern)
		
		expect(subject.output.pattern).to be == pattern
		expect(subject.output).to be_kind_of(Covered::Skip)
	end
	
	it 'can #only a pattern' do
		subject.only(pattern)
		
		expect(subject.output.pattern).to be == pattern
		expect(subject.output).to be_kind_of(Covered::Only)
	end
	
	it 'can specify #root' do
		subject.root(__dir__)
		
		expect(subject.output.path).to be == __dir__
		expect(subject.output).to be_kind_of(Covered::Root)
	end
	
	it 'can #print_summary' do
		io = StringIO.new
		
		subject.print_summary(io)
		
		expect(io.string).to include("* 0 files checked; 0/0 lines executed; 100.0% covered.")
	end
end
