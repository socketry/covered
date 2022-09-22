# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2022, by Samuel Williams.

module RSpecTests
	def test_path
		File.expand_path("rspec/dummy_spec.rb", __dir__)
	end
	
	def spec_helper_path
		File.expand_path("rspec/spec_helper.rb", __dir__)
	end
end
