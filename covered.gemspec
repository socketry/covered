# frozen_string_literal: true

require_relative "lib/covered/version"

Gem::Specification.new do |spec|
	spec.name = "covered"
	spec.version = Covered::VERSION
	
	spec.summary = "A modern approach to code coverage."
	spec.authors = ["Samuel Williams", "Adam Daniels", "Cyril Roelandt", "Shannon Skipper", "chocolateboy"]
	spec.license = "MIT"
	
	spec.cert_chain  = ['release.cert']
	spec.signing_key = File.expand_path('~/.gem/release.pem')
	
	spec.homepage = "https://github.com/ioquatix/covered"
	
	spec.metadata = {
		"funding_uri" => "https://github.com/sponsors/ioquatix/",
	}
	
	spec.files = Dir.glob(['{bake,lib}/**/*', '*.md'], File::FNM_DOTMATCH, base: __dir__)
	
	spec.add_dependency "console", "~> 1.0"
	spec.add_dependency "msgpack", "~> 1.0"
	spec.add_dependency "parser"
	
	spec.add_development_dependency "bundler"
	spec.add_development_dependency "rspec", "~> 3.6"
	spec.add_development_dependency "sus", "~> 0.14"
	spec.add_development_dependency "trenni", "~> 3.6"
end
