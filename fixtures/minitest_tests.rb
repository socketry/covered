# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2022, by Samuel Williams.

module MinitestTests
	def test_path
		File.expand_path("minitest/dummy_test.rb", __dir__)
	end
end
