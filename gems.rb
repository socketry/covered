# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2018-2022, by Samuel Williams.

source "https://rubygems.org"

gemspec

group :maintenance do
	gem "bake-modernize"
	gem "bake-gem"

	gem "bake-github-pages"
	gem "utopia-project"
end

group :test do
	gem "bake-test"
	
	gem "minitest"
	gem "rspec"
end

gem "sus", path: "../sus"
