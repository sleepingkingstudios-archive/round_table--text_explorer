# spec/fixtures/models/locations.rb

require 'fixtures/fixtures'
require 'fixtures/models/edges'
require 'explore/models/location'

module Explore
  module Fixtures
    module Models
      class << self
        def location(key, *args, &block)
          Fixtures[:locations][key] = LocationFixture.new(key, *args, &block)
        end # class method region
      end # class << self
      
      class LocationFixture < Fixture
        def initialize(key, *args, &block)
          args.unshift(key)
          super(Explore::Models::Location, key, *args, &block)
        end # method initialize
        
        def block
          return @block
        end # method block
        
        def params
          return @args[1]
        end # method params
        
        def slug
          return @args[0]
        end # method slug
      end # class LocationFixture
      
      location :marios_pad,       :name => "Mario's Pad"
      location :mushroom_way,     :name => "Mushroom Way"
      location :bandits_way,      :name => "Bandit's Way"
      location :mushroom_kingdom, :name => "Mushroom Kingdom" do
        edges = Explore::Fixtures[:edges]
        edges.each do |key, value|
          go value.location, *value.params
        end # each
      end # location

    end # module Models
  end # module Fixtures
end # module Explore
