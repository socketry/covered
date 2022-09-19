# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2022, by Samuel Williams.

require 'erb'
require 'covered/files'
require 'covered/source'
require 'covered/capture'

let(:code) {<<~ERB}
<ul>
	<% items.each do |item| %>
		<li>
		The item:
		<%= item %>
		</li>
	<% end %>
</ul>
ERB

it "can parse multi-line methods" do
	files = Covered::Files.new
	source = Covered::Source.new(files)
	
	template = ERB.new(code)
	
	capture = Covered::Capture.new(source)
	capture.enable
	template.result_with_hash(items: [1, 2, 3])
	capture.disable
	
	expect(files.paths["(erb)"].counts).not.to be(:include?, 0)
end
