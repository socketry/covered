# Getting Started

This guide explains how to get started with `covered` and integrate it with your test suite.

## Installation

Add this line to your application's `Gemfile`:

``` ruby
gem 'covered'
```

### RSpec Integration

In your `spec/spec_helper.rb` add the following before loading any other code:

``` ruby
require 'covered/rspec'
```

Ensure that you have a `.rspec` file with `--require spec_helper`:

    --require spec_helper
    --format documentation
    --warnings

### Minitest Integration

In your `test/test_helper.rb` add the following before loading any other code:

``` ruby
require 'covered/minitest'
require 'minitest/autorun'
```

In your test files, e.g. `test/dummy_test.rb` add the following at the top:

``` ruby
require_relative 'test_helper'
```

### Template Coverage

Covered supports coverage of templates which are compiled into Ruby code. This is only supported on Ruby 3.2+ due to
enhancements in the coverage interface.

### Partial Summary

    COVERAGE=PartialSummary rspec

This report only shows snippets of source code with incomplete coverage.

### Brief Summary

    COVERAGE=BriefSummary rspec

This report lists several files in order of least coverage.l
