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

RSpec.describe Covered::Files do
	context '#mark' do
		it "can mark lines" do
			subject.mark("program.rb", 2)
			
			expect(subject.paths["program.rb"][2]).to be == 1
		end
		
		it "can mark the same line twice" do
			2.times do
				subject.mark("program.rb", 2)
			end
			
			expect(subject.paths["program.rb"][2]).to be == 2
		end
	end
	
	context '#each' do
		it "enumerates all paths" do
			coverage = subject.mark("program.rb", 2)
			
			enumerator = subject.each
			expect(enumerator.next).to be coverage
		end
	end
end

RSpec.describe Covered::Filter do
	it "accepts everything" do
		expect(subject.accept?("foo")).to be_truthy
	end
end

RSpec.describe Covered::Include do
	let(:files) {Covered::Files.new}
	let(:pattern) {File.join(__dir__, "**", "*.rb")}
	subject {described_class.new(files, pattern)}
	
	it "should match some files" do
		expect(subject.glob).to_not be_empty
	end
	
	let(:path) {subject.glob.first}
	
	it "should defer to existing files" do
		files.mark(path, 5)
		
		paths = subject.collect{|coverage| [coverage.path, coverage.counts]}.to_h
		
		expect(paths).to include(path)
		expect(paths[path]).to be == [nil, nil, nil, nil, nil, 1]
	end
	
	it "should enumerate paths" do
		enumerator = subject.to_enum(:each)
		
		expect(enumerator.next).to be_kind_of Covered::Coverage
	end
end

RSpec.describe Covered::Skip do
	let(:files) {Covered::Files.new}
	subject {described_class.new(files, "file.rb")}
	
	it "should ignore files which match given pattern" do
		subject.mark("file.rb", 1)
		
		expect(files).to be_empty
	end
	
	it "should include files which don't match given pattern" do
		subject.mark("foo.rb", 1)
		
		expect(files).to_not be_empty
		expect(subject.to_h).to include("foo.rb")
	end
end

RSpec.describe Covered::Only do
	let(:files) {Covered::Files.new}
	subject {described_class.new(files, "file.rb")}
	
	it "should ignore files which don't match given pattern" do
		subject.mark("foo.rb", 1)
		
		expect(files).to be_empty
	end
	
	it "should include files which match given pattern" do
		subject.mark("file.rb", 1)
		
		expect(files).to_not be_empty
	end
end

RSpec.describe Covered::Root do
	let(:files) {Covered::Files.new}
	subject {described_class.new(files, "lib/")}
	
	it "should ignore files which don't match root" do
		subject.mark("foo.rb", 1)
		
		expect(files).to be_empty
	end
	
	it "should include files which match root" do
		subject.mark("lib/foo.rb", 1)
		
		expect(files).to_not be_empty
	end
end
