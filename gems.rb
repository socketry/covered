source "https://rubygems.org"

# Specify your gem's dependencies in covered.gemspec
gemspec

gem "sus"

group :maintenance do
	gem "bake-modernize"
	gem "bake-gem"

	gem "bake-github-pages"
	gem "utopia-project"
end

group :test do
	gem "bake-test"
	
	gem "sus"
	gem "minitest"
	gem "rspec"
end