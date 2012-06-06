# spec/fixtures/models/edges.rb

require 'fixtures/fixtures'
require 'explore/models/edge'

module Explore
  module Fixtures
    module Models
      class << self
        def edge(key, *args, &block)
          Fixtures[:edges][key] = EdgeFixture.new(key, *args, &block)
        end # class method region
      end # class << self
      
      class EdgeFixture < Fixture
        def initialize(key, *args)
          args.unshift(key)
          super(Explore::Models::Edge, key, *args)
        end # method initialize
        
        def location
          return @args[0]
        end # method location
        
        def params
          return @args[1]
        end # method params
      end # class EdgeFixture
      
      edge :bandits_way,  :direction => "south", :name => true
      edge :marios_pad,   :name => "Mario's Pad"
      edge :mushroom_way, :direction => "west"
      edge :kero_sewers,  :enabled => false
    end # module Models
  end # module Fixtures
end # module Explore
