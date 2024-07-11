# Configuration

This guide will help you to configure covered for your project's specific requirements.

## Configuration File

You can configure covered by creating a `config/covered.rb` file in your project.

~~~ ruby
# config/covered.rb

def ignore_paths
	super + ["engines/"]
end

def include_patterns
	super + ["bake/**/*.rb"]
end
~~~

See the {ruby Covered::Config} for details on the available configuration options and hooks.
