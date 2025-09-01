# frozen_string_literal: true

require_relative "lib/covered/version"

Gem::Specification.new do |spec|
	spec.name = "covered"
	spec.version = Covered::VERSION
	
	spec.summary = "A modern approach to code coverage."
	spec.authors = ["Samuel Williams", "Adam Daniels", "Aron Latis", "Cyril Roelandt", "Felix Yan", "Michael Adams", "Shannon Skipper", "Stephen Ierodiaconou"]
	spec.license = "MIT"
	
	spec.cert_chain  = ["release.cert"]
	spec.signing_key = File.expand_path("~/.gem/release.pem")
	
	spec.homepage = "https://github.com/socketry/covered"
	
	spec.metadata = {
		"documentation_uri" => "https://socketry.github.io/covered/",
		"funding_uri" => "https://github.com/sponsors/ioquatix/",
		"source_code_uri" => "https://github.com/socketry/covered.git",
	}
	
	spec.files = Dir.glob(["{bake,context,lib}/**/*", "*.md"], File::FNM_DOTMATCH, base: __dir__)
	
	spec.required_ruby_version = ">= 3.2"
	
	spec.add_dependency "console", "~> 1.0"
	spec.add_dependency "msgpack", "~> 1.0"
end
