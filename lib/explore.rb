# lib/explore.rb

require 'round_table'
require 'vendor/plugins'

module RoundTable::Vendor::Plugins
  # The TextExplorer plugin adds functionality for exploring virtual spaces
  # through parsed-text input and short prose output, in the style of classic
  # interactive fiction or adventure games.
  module Explore; end
end # module RoundTable::Vendor::Plugins

include RoundTable::Vendor::Plugins
