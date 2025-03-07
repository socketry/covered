#!/usr/bin/env ruby
# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2022-2025, by Samuel Williams.

require "coverage"

Coverage.start

require_relative "struct"

p Coverage.result
