## General Information

As per the official documentation, `covered` is a modern code-coverage library for Ruby.

Instead of relying only on Ruby’s built-in `Coverage` API, it combines **tracepoints** with  
static analysis from the `parser` gem so it can track _any_ Ruby that eventually gets executed  
(including code produced by `eval`, or templates such as ERB/ HAML that are compiled to Ruby).
Because it knows which lines are _actually_ executable, the reported percentages are usually  
more accurate than classic line-count tools like SimpleCov.

### Installation

Add this line to your application's `Gemfile`:

```
gem 'covered'
```

### Ruby Version

The gem's CI targets Ruby 3.1+; If you are still running older Ruby versions you will need at least 3.0.0 for full feature-parity.

### How to turn coverage on?
The default summary value for COVERAGE is `1`, and it prints out brief summary.

You also have:
    - PartialSummary: prints out snippets around missing lines.
    - FullSummary: prints out every uncovered line in full.
    - Quiet: records silently while still allowing for later consumption.

You can either define these in the environment file, or specificy their values when running the tests as such:
`COVERAGE=1 bundle exec rake test` 
    


## Integration
## Sus Integration

In your `config/sus.rb` add the following:

```ruby
require 'covered/sus'
include Covered::Sus
```

### Integration Implementation Details

As per the above snippet, in order to integrate the code coverage offered by `covered` you need to require the `covered/sus` dependency in your sus configuration file and also include `Covered::Sus` in the same file for it to apply to the runner.

The code contents of `covered/lib/sus.rb` can be found below:

```ruby
module Covered
  module Sus

    def initialize(...)
      super

      # Defer loading the coverage configuration unless we are actually running with coverage startd to avoid performance cost/overhead.
      if ENV["COVERAGE"]
        require_relative "config"
        @covered = Covered::Config.load(root: self.root)
        if @covered.record?
          @covered.start
        end
      else
        @covered = nil
      end
    end

    def after_tests(assertions)
      super(assertions)

      if @covered&.record?
        @covered.finish
        @covered.call(self.output.io)
      end
    end

    def covered
      @covered
    end
  end
end
```

By including the `Covered::Sus` module in the Sus runner, we make sure that we create a `@covered` instance variable (situation specific only to Sus, as the aforementioned gem can spawn multiple runner instances which would require their own instance variable).

As per the above code, by running `@covered.start` the code coverage starts in the initialization of the augmented runner, and it finishes when the `after_tests` hooks are being run.

Therefore the logic more or less reads like

`Covered::Sus` inclusion in Runner
			  |
			  |
			  |
			 \\/
    Runner initialization
  Coverage start (if ENV allows)
			  |
			  |
			  |
			 \\/
           Tests Run
			  |
			  |
			  |
			 \\/
       `after_tests` hooks
   Coverage end + reporting
## RSpec Integration

In your `spec/spec_helper.rb` add the following before loading any other code:

```
require 'covered/rspec'
```

Ensure that you have a `.rspec` file with `--require spec_helper`:

```
--require spec_helper
--format documentation
--warnings
```

### Integration Implementation Details

As per the above snippet, in order to integrate the code coverage offered by `covered` you need to require the `covered/rspec` dependency in your RSpec configuration file.

The code contents of `covered/lib/rspec.rb` can be found below:

```ruby

require_relative "config"
require "rspec/core/formatters"

$covered = Covered::Config.load

module Covered
  module RSpec
    module Policy
      def load_spec_files
        $covered.start

        super
      end

      def covered
        $covered
      end

      def covered= policy
        $covered = policy
      end
    end
  end
end

  

if $covered.record?
  RSpec::Core::Configuration.prepend(Covered::RSpec::Policy)

  RSpec.configure do |config|
    config.after(:suite) do
      $covered.finish
      $covered.call(config.output_stream)
    end
  end
end
```

By requiring the above dependency, we generate a global variable under the name of `$covered`. 

If the test suite is being run with the coverage being tracked, we add a decorator by prepending the `Covered::RSpec::Policy` in `RSpec::Core::Configuration`. This way, when the `load_spec_files` method is called, we ensure the start of the coverage tracking, and once the `after(:suite)` hooks are run, we ensure the finalization and reporting of the coverage.

Dependency requiring in spec_helper.rb
			  |
			  |
			  |
			 \\/
Decorating the `load_spec_files` method (if ENV allows)
			  |
			  |
			  |
			 \\/
 Coverage start at `load_spec_files`
 			   |
			  |
			  |
			 \\/
           Tests Run
			  |
			  |
			  |
			 \\/
       `after(:suite)` hooks
   Coverage end + reporting
## Minitest Integration

In your `test/test_helper.rb` add the following before loading any other code:

```
require 'covered/minitest'
require 'minitest/autorun'
```

In your test files, e.g. `test/dummy_test.rb` add the following at the top:

```
require_relative 'test_helper'
```

### Integration Implementation Details

As per the above snippet, in order to integrate the code coverage offered by `covered` you need to require the `covered/minitest` dependency in your Minitest configuration file.

The code contents of `covered/lib/minitest.rb` can be found below:

```ruby
require_relative "config"

require "minitest"

$covered = Covered::Config.load

module Covered
  module Minitest
    def run(*)
      $covered.start

      super
    end
  end
end

  

if $covered.record?
  Minitest.singleton_class.prepend(Covered::Minitest)

  Minitest.after_run do
    $covered.finish
    $covered.call($stderr)
  end
end
```

By requiring the above dependency, we generate a global variable under the name of `$covered`. 

If the test suite is being run with the coverage being tracked, we add a decorator by prepending the `Covered::Minitest` in `Minitest`. This way, when the `run` method is called, we ensure the start of the coverage tracking, and once the `after_run` hooks are run, we ensure the finalization and reporting of the coverage.


Dependency requiring in test_helper.rb
			  |
			  |
			  |
			 \\/
Decorating the `run` method (if ENV allows)
			  |
			  |
			  |
			 \\/
 Coverage start at `run`
 			   |
			  |
			  |
			 \\/
           Tests Run
			  |
			  |
			  |
			 \\/
       `after_run` hooks
   Coverage end + reporting