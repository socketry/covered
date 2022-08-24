#!/usr/bin/env ruby

path = File.expand_path("struct.rb", __dir__)
iseq = RubyVM::InstructionSequence.compile_file(path)
puts iseq.disassemble
