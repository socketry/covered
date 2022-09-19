#!/usr/bin/env ruby
# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2019-2022, by Samuel Williams.

require 'pry'
require 'parser/current'

ast = Parser::CurrentRuby.parse_file('test.rb')
# ast.location.expression.source

def print_methods(ast)
	if ast.is_a? Parser::AST::Node
		if ast.type == :send
			puts "Calling #{ast.children[1]} on #{ast.location.line}"
		end
		
		ast.children.each do |child|
			print_methods(child)
		end
	end
end

print_methods(ast)

binding.pry
