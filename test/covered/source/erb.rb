# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2022, by Samuel Williams.

require 'erb'
require 'covered/files'
require 'covered/capture'
require 'covered/summary'

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
	
	template = ERB.new(code)
	template.location = [__FILE__, 12]
	
	capture = Covered::Capture.new(files)
	capture.enable
	template.result_with_hash(items: [1, 2, 3])
	capture.disable
	
	expect(files.paths[__FILE__].counts).not.to be(:include?, 0)
	
	# Show the actual coverage:
	# Covered::Summary.new(threshold: nil).call(files, $stderr)
end
