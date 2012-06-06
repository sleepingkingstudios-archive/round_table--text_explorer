# spec/fixtures/models/regions.rb

require 'fixtures/fixtures'
require 'explore/models/region'

module Explore
  module Fixtures
    module Models
      class << self
        def region(key, *args, &block)
          Fixtures[:regions][key] = RegionFixture.new(key, *args, &block)
        end # class method region
      end # class << self
      
      class RegionFixture < Fixture
        def initialize(key, *args, &block)
          args.unshift(key)
          super(Explore::Models::Region, key, *args, &block)
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
      end # class RegionFixture
      
      region :mushroom_kingdom, :name => "Mushroom Kingdom"
    end # module Models
  end # module Fixtures
end # module Explore
