#!/usr/bin/env ruby
# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2022, by Samuel Williams.

Thing = Struct.new(:name, :shape)
thing = Thing.new(:cat, :rectangle)

[
	thing.name,
	thing.shape,
]
