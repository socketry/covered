# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2023, by Samuel Williams.

require 'covered/config'
require 'tmpdir'

describe Covered::Forks do
	def measure_coverage(code)
		Dir.mktmpdir do |root|
			config = Covered::Config.load(root: root)
			test_path = config.policy.expand_path("test.rb")
			
			config.start
			begin
				eval(code, TOPLEVEL_BINDING.dup, test_path, 1)
			ensure
				config.finish
			end
			
			return config.output.to_h[test_path]
		end
	end
	
	it "tracks persistent coverage across forks" do
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
		
		pp coverage
	end
end
