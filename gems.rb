# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2018-2023, by Samuel Williams.

source "https://rubygems.org"

gemspec

group :maintenance do
	gem "bake-modernize"
	gem "bake-gem"
	
	gem "utopia-project"
end

group :test do
	gem "sus"
	gem "xrb"
	
	gem "bake-test"
	gem "bake-test-external"
	
	gem "minitest"
	gem "rspec"
end
