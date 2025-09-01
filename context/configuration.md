# Configuration

This guide will help you to configure covered for your project's specific requirements.

## Quick Start

The simplest way to configure covered is through environment variables:

``` bash
# Basic coverage with default report
COVERAGE=true rspec

# Specific report types
COVERAGE=PartialSummary rspec
COVERAGE=BriefSummary rspec
COVERAGE=MarkdownSummary rspec

# Multiple reports (comma-separated)
COVERAGE=PartialSummary,BriefSummary rspec
```

## Configuration File

For advanced configuration, create a `config/covered.rb` file in your project:

~~~ ruby
# config/covered.rb

def ignore_paths
	super + ["engines/", "app/assets/", "db/migrate/"]
end

def include_patterns
	super + ["bake/**/*.rb", "engines/**/*.rb"]
end

def make_policy(policy)
	super
	
	# Custom policy configuration
	policy.skip(/\/generated\//)
	policy.include("lib/templates/**/*.erb")
end
~~~

## Environment Variables

Covered uses several environment variables for configuration:

| Variable       | Description                       | Default            |
|----------------|-----------------------------------|--------------------|
| `COVERAGE`     | Report types to generate          | `nil` (no reports) |
| `COVERED_ROOT` | Project root directory            | `Dir.pwd`          |
| `RUBYOPT`      | Modified internally for autostart | Current value      |

### Examples

``` bash
# Disable coverage entirely
unset COVERAGE

# Enable default report (BriefSummary)
COVERAGE=true

# Custom project root
COVERED_ROOT=/path/to/project COVERAGE=PartialSummary rspec
```

## Report Types

Covered provides several built-in report types:

### Summary Reports

- **`Summary`** - Full detailed coverage report with line-by-line analysis
- **`FullSummary`** - Complete coverage without threshold filtering
- **`BriefSummary`** - Shows overall statistics + top 5 files with least coverage
- **`PartialSummary`** - Shows only code segments with incomplete coverage + lists 100% covered files
- **`MarkdownSummary`** - Coverage report formatted as Markdown
- **`Quiet`** - Suppresses all output

### Usage Examples

``` ruby
# In config/covered.rb
def make_policy(policy)
	super
	
	# Add multiple reports
	policy.reports << Covered::PartialSummary.new
	policy.reports << Covered::MarkdownSummary.new(threshold: 0.8)
end
```

## Path Configuration

### Ignoring Paths

Default ignored paths include `test/`, `spec/`, `fixtures/`, `vendor/`, and `config/`. Customize with:

``` ruby
def ignore_paths
	super + [
		"engines/",           # Engine directories
		"app/assets/",        # Asset files
		"db/migrate/",        # Database migrations
		"tmp/",               # Temporary files
		"log/",               # Log files
		"coverage/",          # Coverage output
		"public/packs/"       # Webpack outputs
	]
end
```

### Including Patterns

Default includes `lib/**/*.rb`. Extend for additional patterns:

``` ruby
def include_patterns
	super + [
		"app/**/*.rb",        # Application code
		"bake/**/*.rb",       # Bake tasks
		"engines/**/*.rb",    # Engine code
		"lib/templates/**/*.erb"  # Template files (Ruby 3.2+)
	]
end
```

## Advanced Policy Configuration

The `make_policy` method provides fine-grained control:

``` ruby
def make_policy(policy)
	super
	
	# Filter by regex patterns
	policy.skip(/\/generated\//)        # Skip generated files
	policy.skip(/\.generated\.rb$/)     # Skip files ending in .generated.rb
	
	# Include specific files
	policy.include("config/application.rb")
	
	# Only track specific patterns
	policy.only(/^app\//)
	
	# Set custom root
	policy.root(File.expand_path('..', __dir__))
	
	# Enable persistent coverage across runs
	policy.persist!
	
	# Configure reports programmatically
	if ENV['CI']
		policy.reports << Covered::MarkdownSummary.new
	else
		policy.reports << Covered::PartialSummary.new
	end
end
```

## Common Configuration Patterns

### Rails Applications

``` ruby
def ignore_paths
	super + [
		"app/assets/",
		"db/migrate/",
		"db/seeds.rb",
		"config/environments/",
		"config/initializers/",
		"tmp/",
		"log/",
		"public/",
		"storage/"
	]
end

def include_patterns
	super + [
		"app/**/*.rb",
		"lib/**/*.rb",
		"config/application.rb",
		"config/routes.rb"
	]
end
```

### Gem Development

``` ruby
def ignore_paths
	super + ["examples/", "benchmark/"]
end

def include_patterns
	super + ["bin/**/*.rb"]
end

def make_policy(policy)
	super
	
	# Only track the gem's main code
	policy.only(/^lib\//)
end
```

### Monorepo/Multi-Engine

``` ruby
def ignore_paths
	super + [
		"engines/*/spec/",
		"engines/*/test/",
		"shared/fixtures/"
	]
end

def include_patterns
	super + [
		"engines/*/lib/**/*.rb",
		"engines/*/app/**/*.rb",
		"shared/lib/**/*.rb"
	]
end
```

## Template Coverage (Ruby 3.2+)

For projects using ERB, Haml, or other template engines:

``` ruby
def include_patterns
	super + [
		"app/views/**/*.erb",
		"lib/templates/**/*.erb",
		"app/views/**/*.haml"
	]
end

def make_policy(policy)
	super
	
	# Ensure template coverage is enabled
	require 'covered/erb' if defined?(ERB)
end
```

## CI/CD Integration

### GitHub Actions

``` ruby
def make_policy(policy)
	super
	
	if ENV['GITHUB_ACTIONS']
		# Use markdown format for GitHub
		policy.reports << Covered::MarkdownSummary.new
		
		# Fail build on low coverage
		policy.reports << Class.new do
			def call(wrapper, output = $stdout)
				statistics = wrapper.each.inject(Statistics.new) { |s, c| s << c }
				if statistics.ratio < 0.90
					exit 1
				end
			end
		end.new
	end
end
```

### Custom Thresholds

``` ruby
def make_policy(policy)
	super
	
	# Different thresholds for different environments
	threshold = case ENV['RAILS_ENV']
	when 'production' then 0.95
	when 'staging' then 0.90
	else 0.80
	end
	
	policy.reports << Covered::Summary.new(threshold: threshold)
end
```

## Performance Optimization

For large codebases:

``` ruby
def make_policy(policy)
	super
	
	# Skip large generated directories
	policy.skip(/\/node_modules\//)
	policy.skip(/\/vendor\/bundle\//)
	policy.skip(/\/coverage\//)
	
	# Use more efficient reports for large projects
	if Dir['**/*.rb'].length > 1000
		policy.reports << Covered::BriefSummary.new
	else
		policy.reports << Covered::PartialSummary.new
	end
end
```

## Troubleshooting

### Common Issues

**Coverage not working:**
- Ensure `require 'covered/rspec'` (or similar) is at the top of your test helper
- Check that `COVERAGE` environment variable is set
- Verify the configuration file path is correct: `config/covered.rb`

**Missing files in reports:**
- Files must be required/loaded during test execution to be tracked
- Use `include_patterns` to track files not loaded by tests
- Check `ignore_paths` isn't excluding desired files

**Performance issues:**
- Use `BriefSummary` instead of `Summary` for large codebases
- Add more specific patterns to `ignore_paths`
- Use `policy.only()` to limit scope

**Template coverage not working:**
- Requires Ruby 3.2+ for full template support
- Ensure template engines are loaded before coverage starts
- Check that template files match `include_patterns`

### Debug Configuration

``` ruby
def make_policy(policy)
	super
	
	# Debug: print current configuration
	if ENV['DEBUG_COVERAGE']
		puts "Ignore paths: #{ignore_paths}"
		puts "Include patterns: #{include_patterns}"
		puts "Root: #{@root}"
	end
end
```

See the {ruby Covered::Config} class for complete API documentation.
