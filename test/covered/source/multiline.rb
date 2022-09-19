require 'covered/files'
require 'covered/source'
require 'covered/capture'

let(:code) {<<~RUBY}
output = String.new
begin
	output << "
".freeze; end
RUBY

it "can parse multi-line methods" do
	files = Covered::Files.new
	source = Covered::Source.new(files)
	
	coverage = source.add("test.rb", code)
	
	capture = Covered::Capture.new(files)
	capture.execute("test.rb", code)
	
	expect(coverage.counts).not.to be(:include?, 0)
end
