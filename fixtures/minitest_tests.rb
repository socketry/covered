module MinitestTests
	def test_path
		File.expand_path("minitest/dummy_test.rb", __dir__)
	end
end
