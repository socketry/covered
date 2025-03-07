# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2022-2025, by Samuel Williams.

require "erb"
require "covered/files"
require "covered/capture"
require "covered/summary"

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
	skip "Unsupported Ruby Version" unless RUBY_VERSION >= "3.2"
	
	files = Covered::Files.new
	
	template = ERB.new(code)
	template.location = [__FILE__, 12]
	
	capture = Covered::Capture.new(files)
	capture.start
	template.result_with_hash(items: [1, 2, 3])
	capture.finish
	
	expect(files.paths[__FILE__].counts).not.to be(:include?, 0)
	
	# Show the actual coverage:
	# Covered::Summary.new(threshold: nil).call(files, $stderr)
end
