#!/usr/bin/env ruby
# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2019-2022, by Samuel Williams.

require_relative '../../lib/covered/minitest'
require 'minitest/autorun'

class DummyTest < Minitest::Test
	def test_hello_world
		assert_equal "Hello World", "Hello World"
	end
end
