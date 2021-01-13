# Copyright, 2019, by Samuel G. D. Williams. <http://www.codeotaku.com>
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

require 'covered/persist'

require_relative 'wrapper_examples'

RSpec.describe Covered::Persist do
	include_context Covered::Wrapper
	
	let(:coverage) {Covered::Coverage.new(__FILE__)}
	let(:record) {subject.serialize(coverage)}
	
	it "can serialize coverage" do
		expect(record[:path]).to be == __FILE__
	end
	
	context "with some data" do
		let(:path) {"test.db"}
		let(:writer) {described_class.new(Covered::Wrapper.new(Covered::Files.new), path)}
		let(:reader) {described_class.new(Covered::Wrapper.new(Covered::Files.new), path)}
		
		before(:each) {writer.mark(__FILE__, 1, 2)}
		after(:each) {File.unlink(path) if File.exist?(path)}
		
		it "can write to file" do
			expect {writer.save!}.to_not raise_error
			expect(File.size(path)).to_not be_zero
		end
		
		it "can read from file" do
			expect {writer.save!}.to_not raise_error
			expect {reader.load!}.to_not raise_error
			expect {|block| reader.output.each(&block)}.to yield_control.once
			reader.output.each do |file|
				expect(file[1]).to be == 2
			end
		end

		context "with UTF-8 internal encoding" do
			before(:each) {Encoding.default_internal = Encoding::UTF_8}
			
			it "should read and write without error" do
				expect {writer.save!}.to_not raise_error
				expect {reader.load!}.to_not raise_error
			end
		end
	end
end
