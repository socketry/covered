# Covered [![Build Status](https://travis-ci.com/ioquatix/covered.svg)](hhttps://travis-ci.com/ioquatix/covered)

Covered uses modern Ruby features to generate comprehensive coverage, including support for templates which are compiled into Ruby. **This only works with Ruby 2.6 and it's experimental support for RubyVM::AST**

![Screenshot](media/example.png)

## Motivation

Existing Ruby coverage tools are unable to handle `eval`ed code. This is because the `coverage` module built into Ruby doesn't expose the necessary hooks to capture it. With Ruby 2.6, `RubyVM::AST.parse(source)` came in to existance, which gives us a fine grained tool for computing initial source coverage (i.e. what lines are executable), and thus making it possible to compute coverage for "templates".

It's still tricky to do it correctly, but it is feasible now to compute coverage of web application "views" by using this technique. This gem is an exploration to see what is possible.

## Installation

Add this line to your application's Gemfile:

	gem 'covered'

And then execute:

	$ bundle

Or install it yourself as:

	$ gem install covered

## Usage

For `rspec`, simply include the following from your `spec_helper.rb`

```ruby
require 'covered/rspec'
```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

## License

Released under the MIT license.

Copyright, 2018, by [Samuel G. D. Williams](http://www.codeotaku.com/samuel-williams).

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
