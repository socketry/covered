#!/usr/bin/env ruby
# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2022, by Samuel Williams.

path = File.expand_path("struct.rb", __dir__)
iseq = RubyVM::InstructionSequence.compile_file(path)
puts iseq.disassemble
