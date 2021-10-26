source "https://rubygems.org"

# Specify your gem's dependencies in covered.gemspec
gemspec

group :maintenance do
	gem "bake-modernize"
	gem "bake-gem"
end
