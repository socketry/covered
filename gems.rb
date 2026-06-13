# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2018-2025, by Samuel Williams.

source "https://rubygems.org"

gemspec

group :maintenance do
	gem "bake-modernize"
	gem "bake-gem"
	gem "bake-releases"
	
	gem "agent-context"
	
	gem "utopia-project"
	gem "decode"
end

group :test do
	gem "sus"
	gem "xrb"
	
	gem "rubocop"
	gem "rubocop-md"
	gem "rubocop-socketry"
	
	gem "bake-test"
	gem "bake-test-external"
	
	gem "minitest"
	gem "rspec"
end
