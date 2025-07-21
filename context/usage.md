## General Information

As per the official documentation, `covered` is a modern code-coverage library for Ruby.

Instead of relying only on Ruby’s built-in `Coverage` API, it combines **tracepoints** with  
static analysis from the `parser` gem so it can track _any_ Ruby that eventually gets executed  
(including code produced by `eval`, or templates such as ERB/ HAML that are compiled to Ruby).
Because it knows which lines are _actually_ executable, the reported percentages are usually  
more accurate than classic line-count tools like SimpleCov.

## Installation

Add this line to your application's `Gemfile`:

```ruby
gem 'covered'
```

## Configuration

### Configure what you see

Under the hood, `covered` uses a single environment variable `COVERAGE` to:
1. turn the coverage tracking on/ off
2. allow the user to select how much detail to be printed

By default, when the `COVERAGE` is not specifically set anywhere, you will not see anything, and nothing will be stored during the runs.

You can modify this behavior either by defining the environment variable or specifying it when running the tests command. Your choices of values are:
1. `BriefSummary` - you see a brief summary showcasing the overall percentage of line coverage.
	- Ideally you would use this for quick feedback locally
	- You can also use this to set a threshold through Github Actions around merging rules in Pull Requests.
2. `PartialSummary` - you see contextual snippets around missing lines
	- Ideally you would use this for quickly investigating missing coverage in specific files
	- You can also use this to set a threshold through Github Actions around merging rules in Pull Requests, and also deliver information about which lines are not tested to the developer.
3. `FullSummary` - you see every line, both covered and uncovered, which may be overwhelming
	- Ideally you would use this when doing a deep dive that requires verbosity.
4. `Quiet` - you do not see anything in the console but the coverage is saved internally for later usage
	- Ideally used in CI pipelines.

### Configure file choices for coverage

You can configure covered by creating a `config/covered.rb` file in your project.

```ruby
def ignore_paths
	super + ["engines/"]
end

def include_patterns
	super + ["bake/**/*.rb"]
end
```

1. `ignore_paths` specifies which paths to ignore when computing coverage for a given project.
2. `include_patterns` specifies which paths to include when computing coverage for a given project.

More information around the Configuration possibilities can be found here: https://socketry.github.io/covered/source/Covered/Config/index.html.

One possibly helpful functionality to take note of is that you can override the `make_policy` method in order to implement your own policy.
## Integration

### Sus Integration

In your `config/sus.rb` add the following:

```ruby
require 'covered/sus'
include Covered::Sus
```
### RSpec Integration

In your `spec/spec_helper.rb` add the following before loading any other code:

```ruby
require 'covered/rspec'
```

Ensure that you have a `.rspec` file with `--require spec_helper`:

```plain
--require spec_helper
--format documentation
--warnings
```

### Minitest Integration

In your `test/test_helper.rb` add the following before loading any other code:

```ruby
require 'covered/minitest'
require 'minitest/autorun'
```

In your test files, e.g. `test/dummy_test.rb` add the following at the top:

```ruby
require_relative 'test_helper'
```


## Coverage Improvement

The taxonomy of tests isn't really relevant for the purpose of improving the coverage and the safety of your codebase.

You are going to think about tests by referring to the level of software processes that they test. When trying to improve coverage, you must first understand what the purpose of the on-going process is, with the scope of coverage in mind:
	1. Verifying individual components - you are going to be writing Unit Tests.
	2. Verifying interaction between multiple units - you are going to be writing Integration Tests.
	3. Verifying end-to-end-workflows - you are going to be writing System Tests.
