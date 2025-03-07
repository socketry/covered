# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2018-2025, by Samuel Williams.

source "https://rubygems.org"

gemspec

group :maintenance do
	gem "bake-modernize"
	gem "bake-gem"
	gem "bake-releases"
	
	gem "utopia-project"
end

group :test do
	gem "sus"
	gem "decode"
	gem "rubocop"
	
	gem "xrb"
	
	gem "bake-test"
	gem "bake-test-external"
	
	gem "minitest"
	gem "rspec"
end
