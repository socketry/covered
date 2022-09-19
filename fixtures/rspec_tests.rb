module RSpecTests
	def test_path
		File.expand_path("rspec/dummy_spec.rb", __dir__)
	end
end
