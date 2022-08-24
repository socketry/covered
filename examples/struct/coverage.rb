#!/usr/bin/env ruby

require "coverage"

Coverage.start

require_relative 'struct'

p Coverage.result
