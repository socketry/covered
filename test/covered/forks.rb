# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2023-2025, by Samuel Williams.

require "covered/config"
require "tmpdir"

describe Covered::Forks do
	def measure_coverage(code)
		Dir.mktmpdir do |root|
			config = Covered::Config.load(root: root)
			test_path = config.policy.expand_path("test.rb")
			
			config.start
			begin
				File.write(test_path, code)
				
				if block_given?
					yield test_path
				else
					eval(code, TOPLEVEL_BINDING.dup, test_path, 1)
				end
			ensure
				config.finish
			end
			
			return config.output.to_h[test_path]
		end
	end
	
	it "tracks persistent coverage across forks" do
		skip "Unsupported Ruby Version" unless RUBY_VERSION >= "3.2.1"
		
		coverage = measure_coverage(<<~RUBY)
			3.times do
				Object.new
			end
			
			pid = fork do
				3.times do
					Object.new
				end
			end
			
			Process.wait(pid)
		RUBY
		
		expect(coverage.counts).to be == [
			nil, 1, 3, nil, nil, 1, 1, 3, nil, nil, nil, 1
		]
	end
	
	it "tracks persistent coverage across processes" do
		skip "Unsupported Ruby Version" unless RUBY_VERSION >= "3.2.1"
		
		code = <<~RUBY
			3.times do
				Object.new
			end
		RUBY
		
		coverage = measure_coverage(code) do |path|
			pid = spawn("ruby", path)
			
			Process.wait(pid)
		end
		
		expect(coverage.counts).to be == [
			nil, 1, 3
		]
	end
end
