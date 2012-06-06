# lib/explore/models/region.rb

require 'util/argument_validator'
require 'explore/models/location'

module Explore::Models
  class Region
    # A Region is a subset of the graph of explorable spaces, usually
    # corresponding to some meaningful geographic feature such as a town, a
    # road, a mountain, or a dungeon. Each region has one or more Locations.
    
    include RoundTable::Util::ArgumentValidator
    
    def initialize(slug, params = {}, &block)
      # @param slug : the name of the region. Must be a string or a symbol.
      # @param params (optional) : additional initialization information.
      #   Must be a hash or nil.
      #   @key :name (optional) : the human-readable name of the location. If
      #     omitted, the name is automatically generated from the slug.
      # @param &block (optional) : a block evaluated by a generated
      #   RegionParser. Region can also be populated manually.
      
      validate_argument slug,   :as => "slug",   :type => [String, Symbol]
      validate_argument params, :as => "params", :type => [Hash], :allow_nil? => true
      
      config = { name: nil }
      config.update(params)
      
      @slug = RoundTable::Util::TextProcessor.to_snake_case(slug.to_s).intern
      @name = config[:name] || @slug.to_s.split("_").map { |str| str.capitalize }.join(" ")
      @locations = {}
    end # method initialize
    
    attr_reader :name, :slug
    
    #####################
    # Location Management
    
    attr_reader :locations
    
    def add_location(location, force = false)
      validate_argument location, :as => "location", :type => Explore::Models::Location
      
      key = location.slug
      if @locations[key] && !force
        raise ArgumentError.new "Location #{key} already exists."
      else
        locations[key] = location
      end # if-else
    end # method add_location
    
    def build_location(slug, params = nil, &block)
      return Location.new slug, params, &block
    end # method build_location
    
    def has_location(location)
      validate_argument location, :as => "location", :type => [Symbol, Explore::Models::Location]
      key = (location.is_a? Symbol) ? location : location.slug
      
      @locations.include?(key)
    end # method has_location
  end # class Region
end # module Explore::Models
