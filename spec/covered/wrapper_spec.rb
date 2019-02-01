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

require 'covered/files'

RSpec.describe Covered::Wrapper do
	let(:output) {double}
	subject {described_class.new(output)}
	
	it 'passes #mark through' do
		expect(output).to receive(:mark).with("fleeb.rb", 5, 1)
		
		subject.mark("fleeb.rb", 5, 1)
	end
	
	it 'passes #enable through' do
		expect(output).to receive(:enable)
		
		subject.enable
	end
	
	it 'passes #disable through' do
		expect(output).to receive(:disable)
		
		subject.disable
	end
	
	it 'passes #each through' do
		expect(output).to receive(:each)
		
		subject.each do
		end
	end
end
