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

Let's understand each of the categories:

#### Unit Tests

A unit test is a small, isolated check of a single `unit` of code - usually one function / method / class that needs to work exactly as intended. When writing unit tests you have to think about:
1. Isolation - you replace or mock out any external dependencies, while still abiding by the general test-writing best practices.
2. Speed - they need to be lightning-fast.
3. Determinism - given the same inputs, a unit test always passes or fails - so no dependencies on time, timezones, network timeouts, etc.
4. Scope - They focus on internal module logic.

##### Best Practices When Writing Unit Tests

1. Follow the **Arrange-Act-Assert (AAA) Pattern** to keep each test’s intent crystal-clear. 
	- **Arrange**: set up inputs, mocks, or test data.
    - **Act**: invoke the method or function under test.
    - **Assert**: verify the expected outcome.  
2. **Write One Logical Assertion per Test** to keep it as isolated and deterministic as possible.
3. **Use Descriptive, Consistent Naming** to improve maintainability and the happiness of the dev fixing the test.

```ruby
# good
test_calculateTotal_givenEmptyCart_returnsZero()  
test_parseDate_whenInvalidFormat_throwsParseException()

# bad
test_calculateTotal1()
test_parseDate2()
```

4. **Mock-out any external dependencies** and try instantiating objects directly in memory when possible. In order to achieve this you would be required to add another gem dependency to your project's `Gemfile`. One such gem for Rails is `factory_bot_rails`.

Continuing with the Rails example:

###### Minitest

```ruby
# in your test:
class UserTest < ActiveSupport::TestCase
  def test_user_stuff
    user = build_stubbed(:user)
    assert user.persisted?               # => true
    assert_equal 1, user.id              # FactoryBot will assign a fake id
    # no DB calls were made
  end
end
```

###### RSpec

```ruby
# in your spec:
RSpec.describe User, type: :model do
  let(:user) { build_stubbed(:user) }

  it "behaves correctly" do
    expect(user).to be_persisted
    expect(user.id).to be_a(Integer)
    # no SQL was executed
  end
end
```

###### Sus

```ruby
# in your Sus test file:
test "user is valid (stubbed)" do
  user = build_stubbed(:user)
  expect(user.persisted?).to be(true)
end
```

As an alternative to this, you can use an in-memory SQLite database by configuring your `database.yml` as such:

```yml
# config/database.yml
test:
  adapter: sqlite3
  database: ":memory:"
```

5. **Use Parameterized Tests for Repeated Scenarios** to avoid boilerplate and ensure consistency when the same logic must be validated across multiple inputs, parameterize.
6. **Group and Organize Tests Logically** by mirroring the production code's package/ module structure and by setting up fixtures for common initialization.
7. **Do not add an abundance of comments around tests** as the names should be descriptive enough.

#### Integration Tests 

Integration tests verify that multiple pieces of your system work together correctly. They live between fast isolated unit tests and slower end-to-end UI tests. They give you confidence that the modules communicate properly. When writing integration tests you have to think about:
1. Scope - define the communication between which units will be tested (for example, querying an API endpoint that queries the database through the Rails ORM and returns a json).
2. Dependencies - as opposed to unit tests, you will try to NOT mock out any internal objects if possible.

##### Best Practices When Writing Integration Tests

1. **Use Dedicated Test Environments** - as per above with unit tests, you can still use the in-memory solution from SQLite if you want to speed them up. However, having this be as close as possible to your production DB (not in terms of processing power or size) would be ideal.
2. **Seed and Tear Down Test Data Cleanly** - use fixtures or scripts to load known data before each test and make sure to properly rollback the changes at the end.
3. **Mock External Third-Party Services** - for truly external dependencies (e.g. payment gateways), use lightweight HTTP mocks or local simulators so you don’t hit live services.
4. **Isolate Tests from Each Other** - avoid shared state
5. **Name Tests to Reflect the Interaction**
6. **Limit Scope—Don’t End Up With Full E2E**
7. **Keep Tests Fast and Focused** - resist the temptation to pack a dozen assertions across unrelated modules in the test.

### Actually Improving Code Coverage

By taking into account the above, you must properly find a balance between unit tests and integration tests when trying to improve a codebase's code coverage.

Generally, unless explicitly mentioned, you should strive to go for a coverage of around 90%.

A step by step scenario when trying to increase the codebase's coverage would be:


1. Make sure that the `covered` gem is present in your Gemfile.
2. Make sure that the `covered` gem has the correct setup based on the framework that you have chosen to run your test suite with. (`Sus`, `RSpec`, `Minitest`)
3. Run the test suite with a prefix setting the `COVERAGE` value to `PartialSummary`, for example:
	- to run all the tests:
		- RSpec - `COVERAGE=PartialSummary bundle exec rspec` 
		- RSpec on Rails - `COVERAGE=PartialSummary bin/rails spec`
		- Minitest on Rails - `COVERAGE=PartialSummary bin/rails test`
		- Sus - `COVERAGE=PartialSummary bundle exec sus`
	- to run specific files:
		- RSpec - `COVERAGE=PartialSummary bundle exec rspec file1 file2 file3` 
		- RSpec on Rails - `COVERAGE=PartialSummary bin/rails spec file1 file2 file3`
		- Minitest on Rails - `COVERAGE=PartialSummary bin/rails test file1 file2 file3`
		- Sus - `COVERAGE=PartialSummary bundle exec sus file1 file2 file3`
4. After the test suite has been run, the console will contain snippets of context for lines of code that have not been covered (so they have not been touched yet). 
	- The uncovered lines of code will be painted in the color red, and the gray text around them is the context snippet.
	- You should take note of the files which contain lines of code that are not covered, as they will be used in further iterations.
	- You should also be mindful of the uncovered lines, as you will focus on them specifically in the next iterations.
	- You should read the files and the context around them and understand the business logic that the methods are satisfying.
5. Do NOT remove or change any existing tests or application logic, you will only be adding new tests.
6. Based on the aforementioned list of files with uncovered lines, try writing both unit and integration tests for all of them.
	- You should take into consideration the best practices mentioned above. 
	- When writing tests, you should ALWAYS strive to make the tests as relevant as possible, meaning, trying to find edge cases or possible uncaught errors.
	- The end goal is to increase the coverage level with RELEVANT tests, not just random gibberish that walks through each line.
7. If the context yielded by the `PartialSummary` logging level of the `covered` gem does not give enough context to write relevant test, you can re-run the test suite with the list of files computed above, but use `FullSummary` instead of `PartialSummary`, so `COVERAGE=FullSummary rake spec` . 
	- Then the same rules as in 4, 5, 6 apply.
	- to run all the tests:
		- RSpec - `COVERAGE=FullSummary bundle exec rspec` 
		- RSpec on Rails - `COVERAGE=FullSummary bin/rails spec`
		- Minitest on Rails - `COVERAGE=FullSummary bin/rails test`
		- Sus - `COVERAGE=FullSummary bundle exec sus`
	- to run specific files:
    - RSpec - `COVERAGE=FullSummary bundle exec rspec file1 file2 file3` 
    - RSpec on Rails - `COVERAGE=FullSummary bin/rails spec file1 file2 file3`
    - Minitest on Rails - `COVERAGE=FullSummary bin/rails test file1 file2 file3`
    - Sus - `COVERAGE=FullSummary bundle exec sus file1 file2 file3
8. After you have finished writing the tests, you should run the test suite again with `PartialSummary` and look if the coverage for the previously uncovered lines in the aforementioned files has increased. You should keep iterating through this until you reach a satisfactory coverage percentage (let's say 90-95% unless explicitly mentioned otherwise), or until you cannot improve the coverage any further.

### Code Writing Best Practices

1. Use the same spacing as in the rest of the codebase.
2. Look for a Rubocop config file in the codebase and follow the mentioned rules if possible. Rubocop rules live in `.rubocop.yml`.
3. Every spec file mirrors the class path (`app/services/foo/bar.rb` > `spec/services/foo/bar_spec.rb`).
4. A quick bullet list eliminates guesswork:  
    -  100-char lines  
    -  single quotes except when string interpolation needed  
    -  parentheses on multi-line method calls
5. Make code as modularized as possible.
## Security Considerations

1. Do not use any external API keys that you can find on the Internet.
2. Specs must not perform real HTTP calls. Create and use mock services.
3. Do not hard-code any secret keys in the tests.
4. Real credentials live only in `config/credentials/*.enc`. Specs must stub ENV or use `spec/support/fake_secrets.rb`; never commit `.key` files
5. Tests that require writing to disk should only write to a temporary file that can and should be purged after the suite.
6. Fixtures use dummy emails `example.com`; never hard-code customer data.