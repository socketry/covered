#!/usr/bin/env ruby

Thing = Struct.new(:name, :shape)
thing = Thing.new(:cat, :rectangle)

[
	thing.name,
	thing.shape,
]
