# lib/text_explorer/explore/location.rb

require 'controllers/action_delegate'
require 'util/argument_validator'
require 'util/text_processor'
require 'text_explorer/parsers/location_parser'

module TextExplorer::Explore
  # A Location is a node in the graph of explorable spaces. Each location has
  # zero or more actions that can be performed on it directly, zero or more
  # delegates that also respond to actions, and zero or more edges that connect
  # to other nodes. Each location belongs to a Region.
  class Location < RoundTable::Controllers::ActionDelegate
    include RoundTable::Util::ArgumentValidator
    
    def initialize(slug, params, &block)
      # @param slug : the name of the location. Must be a string or a symbol.
      # @param params : additional initialization information. Must be a hash.
      #   @key :region : the region containing this location. Must be a
      #     TextExplorer::Explore::Region
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
      validate_argument params, :as => "params", :type => Hash
      validate_argument params[:region], :as => "params[:region]", :type => Region
      
      config = { :name => nil }
      config.update(params)
      
      @slug = RoundTable::Util::TextProcessor.to_snake_case(slug.to_s).intern
      @name = config[:name] || @slug.to_s.split("_").map { |str| str.capitalize }.join(" ")
      
      @region = config[:region]
      @edges = Hash.new
      
      self.description = config[:description] || "A rather generic-looking location. Nothing to see here."
      
      if block_given?
        parser = TextExplorer::Parsers::LocationParser.new(self)
        parser.instance_eval &block
      end # if
    end # constructor
    
    #################
    # Other Locations
    
    attr_reader :edges
    
    def add_edge(name, params = {})
      # @param name : the name of the other location. Must be unique.
      # @param params (optional) : additional parameters
      #   @key :if (optional) : if this parameter evaluates to false, the
      #     player cannot go to the destination and the edge does not appear in
      #     a list of valid locations.
      #   @key :location (optional) : the slug of the destination location. If
      #     omitted, the location is automatically generated from the name.
      #   @key :particle (optional) : specifies whether the particle "to"
      #     is required, e.g. "go north" vs. "go to Village"
      #   @key :region (optional) : the slug of the destination region. If
      #     omitted, uses the current region.
      #   @key :unless (optional) : if this parameter evaluates to true, the
      #     player cannot go to the destination and the edge does not appear in
      #     a list of valid locations.
      
      validate_argument name, :as => "name", :type => [String, Symbol]
      name = name.to_s.split("_").map { |str| str.capitalize }.join(" ") if name.is_a? Symbol
      
      raise ArgumentError.new "location #{name} is already defined" if @edges.has_key? name
      
      params[:location] ||= RoundTable::Util::TextProcessor.to_snake_case(name).intern
      params[:region] ||= self.region.slug
      
      validate_argument params[:if], :as => "params[:if]", :allow_nil? => true, :type => Proc
      validate_argument params[:unless], :as => "params[:unless]", :allow_nil? => true, :type => Proc
      
      @edges[name] = params
    end # method add_edge
    
    def has_edge?(name)
      @edges.has_key? name
    end # method has_edge?

    def has_location?(name)
      return false unless self.has_edge? name
      edge_data = @edges[name]
      
      return false unless edge_data[:if].nil? or self.instance_eval(&edge_data[:if])
      return false unless edge_data[:unless].nil? or !self.instance_eval(&edge_data[:unless])

      return true
    end # method has_location?
    
    def locations
      edges.keys.keep_if { |key| self.has_location? key }
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
      raise ArgumentError.new "expected TextExplorer::Explore::Region, received #{value.class}" unless value.is_a? TextExplorer::Explore::Region
      @region = value
    end # mutator region=
  end # class Location
end # module TextExplorer::Explore
