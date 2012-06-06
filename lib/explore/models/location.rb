# lib/explore/models/location.rb

require 'controllers/action_delegate'
require 'util/argument_validator'
require 'util/text_processor'

require 'explore/models/edge'
require 'explore/parsers/location_parser'

module Explore::Models
  # A Location is a node in the graph of explorable spaces. Each location has
  # zero or more actions that can be performed on it directly, zero or more
  # delegates that also respond to actions, and zero or more edges that connect
  # to other nodes. Each location belongs to a Region.
  class Location < RoundTable::Controllers::ActionDelegate
    include RoundTable::Util::ArgumentValidator
    
    def initialize(slug, params = nil, &block)
      # @param slug : the name of the location. Must be a string or a symbol.
      # @param params : additional initialization information. Must be a hash.
      #   @key :region (optional) : the region containing this location. Must
      #     be a Explore::Models::Region
      #   @key :name (optional) : the human-readable name of the location. If
      #     omitted, the name is automatically generated from the slug.
      #   @key :description (optional) : a short string displayed to the player
      #     when entering the location. Can be a string or a block, which will
      #     be evaluated in the context of the location instance and must
      #     return a string.
      # @param &block (optional) : a block evaluated by a generated
      #   LocationParser (to avoid namespace collisions). Location can also be
      #   populated manually.
      
      validate_argument slug, :as => "slug", :type => [String, Symbol]
      validate_argument params, :as => "params", :type => Hash, :allow_nil? => true
      
      config = { :name => nil }
      config.update(params) if params.is_a? Hash
      
      @slug = RoundTable::Util::TextProcessor.to_snake_case(slug.to_s).intern
      @name = config[:name] || @slug.to_s.split("_").map { |str| str.capitalize }.join(" ")
      
      @region = config[:region]
      @edges = Hash.new
      
      self.description = config[:description] || "A rather generic-looking location. Nothing to see here."
      
      if block_given?
        parser = Explore::Parsers::LocationParser.new(self)
        parser.instance_eval &block
      end # if
    end # constructor
    
    #################
    # Other Locations
    
    attr_reader :edges
    
    # Adds a directed (outgoing) connection to another location that the player
    # can navigate, e.g. through the "go" action.
    # 
    # @param location: the name of the other location.
    # @param params: additional parameters; see Edge.new for full details.
    def add_edge(location, params = {})
      if self.has_edge? location
        self.edges[location].update(params)
      else
        edge = Explore::Models::Edge.new location, params
        @edges[edge.location] = edge
      end # if-else
    end # method add_edge
    
    def has_edge?(name)
      @edges.has_key? name
    end # method has_edge?
    
    def has_direction?(name)
      self.directions.include? name
    end # method has_direction?
    
    def has_location?(name)
      self.locations.include? name
    end # method has_location?
    
    def directions
      directions = Hash.new
      self.edges.each do |key, loc|
        directions.update({ loc.direction => key }) unless loc.direction.nil?
      end # each
      return directions
    end # method directions
    
    def locations
      locations = Hash.new
      self.edges.each do |key, loc|
        locations.update({ loc.name => key }) unless loc.name.nil?
      end # each
      return locations
    end # method locations
    
    ########################
    # Accessors and Mutators
    
    attr_reader :name, :region, :slug
    
    def continent
      self.region.continent
    end # method continent
    
    def description
      @description.respond_to?(:call) ? self.instance_eval(&@description) : @description
    end # accessor description
    
    def description=(value)
      raise ArgumentError.new "expected String or Proc, received #{value.class}" unless value.is_a?(String) or value.respond_to?(:call)
      @description = value
    end # mutator description=
    
    def name=(value)
      raise ArgumentError.new "expected String, received #{value.class}" unless value.is_a? String
      @name = value
    end # mutator name=
    
    def region=(value)
      raise ArgumentError.new "expected Explore::Models::Region, received #{value.class}" unless value.is_a? Explore::Models::Region
      @region = value
    end # mutator region=
  end # class Location
end # module Explore::Models
