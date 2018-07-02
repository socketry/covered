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

require 'covered/statistics'

RSpec.describe Covered::Statistics do
	context 'initial state' do
		it "is zero" do
			expect(subject.count).to be 0
			expect(subject.executable_count).to be 0
			expect(subject.executed_count).to be 0
		end
		
		it "is complete" do
			expect(subject).to be_complete
		end
	end
	
	context 'after adding full coverage' do
		let(:coverage) {Covered::Coverage.new("foo.rb", [nil, 1])}
		
		before(:each) do
			subject << coverage
		end
		
		it "has one entry" do
			expect(subject.count).to be 1
			expect(subject.executable_count).to be 1
			expect(subject.executed_count).to be 1
		end
		
		it "is complete" do
			expect(subject).to be_complete
		end
	end
	
	context 'after adding partial coverage' do
		let(:coverage) {Covered::Coverage.new("foo.rb", [nil, 1, 0])}
		
		before(:each) do
			subject << coverage
		end
		
		it "has one entry" do
			expect(subject.count).to be 1
			expect(subject.executable_count).to be 2
			expect(subject.executed_count).to be 1
		end
		
		it "is not complete" do
			expect(subject).to_not be_complete
		end
	end
end
