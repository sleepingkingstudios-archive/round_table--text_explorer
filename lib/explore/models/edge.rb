# lib/explore/models/edge.rb

require 'util/argument_validator'

module Explore::Models
  # An Edge object describes the relation of one location to another, which
  # allows the player to travel from the former to the latter. Each edge must
  # unambiguously determine the destination location, as well as provide the
  # text feedback for describing movement options to the player.
  class Edge
    include RoundTable::Util::ArgumentValidator
    
    # Constructor. Validates required params and then feeds the params directly
    # to update().
    # @param location: Expects value, responding to :slugify. Slug of the
    #   destination location.
    # @param params (optional): Expects key-value store, responding to :[],
    #   :keys, :values
    # * @key region (optional): Expects value, responding to :slugify. Slug of
    #   the destination region. If omitted, assumes region is the same as the
    #   current region.
    # * @key direction (optional): String of the direction of the destination
    #   location, e.g. "north" or "up"; used for navigation without particle,
    #   e.g. "go north" or "go up".
    # * @key name (optional): String of the location name of the destination
    #   location, e.g. "Throne Room" or "Haunted House"; used for navigation
    #   with particle, e.g. "go to Throne Room" or "go to Haunted House". If
    #   omitted, value depends on params[:direction]. If nil, name defaults to
    #   formatted params[:location], otherwise name is nil. To force name to
    #   match params[:location] when a direction is given, use :name => true.
    # * @key description (optional): String used for reflection when the player
    #   asks where he/she can go. If omitted, is generated from direction
    #   and/or name.
    # * @key enabled (optional): Boolean for whether or not the edge can be
    #   traveled and is currently visible.
    # * @key visible (optional): Boolean for whether or not the edge appears in
    #   reflection, e.g. the "where" action. Edges that are disabled (see
    #   above) are never visible regardless of the current visible property.
    def initialize(location, params = {})
      config = Hash.new
      %w(region direction name description).each do |key| config[key.intern] = nil end
      %w(enabled visible).each do |key| config[key.intern] = true end
      
      validate_argument location, :as => "location", :respond_to? => :slugify
      validate_argument params, :as => "params", :respond_to? => [:[], :keys, :values]
      config.update(params)
      config.update( :location => location )
      
      self.update(config)
    end # method initialize
    
    # Wrapper method for updating multiple parameters at once.
    def update(params = {})
      validate_argument params, :as => "params", :respond_to? => [:[], :keys, :values]
      
      params.each do |key, value|
        self.send :"#{key}=", value if self.respond_to? :"#{key}="
      end # each
    end # method update
    
    ########################
    # Accessors and Mutators
    
    attr_reader :location, :region, :direction, :enabled
    
    def location=(location)
      validate_argument location, :as => "location", :respond_to? => :slugify
      @location = location.slugify
    end # mutator location=
    
    def region=(region)
      validate_argument region, :as => "region", :respond_to? => :slugify unless region.nil?
      @region = region.nil? ? nil : region.slugify
    end # mutator region=
    
    def direction=(direction)
      validate_argument direction, :as => "direction", :respond_to? => :to_s unless direction.nil?
      @direction = direction.nil? ? nil : direction.to_s
      
      # Generates name from location if direction and name are nil; guards
      # against name staying nil when removing direction in an update.
      self.name = true if self.direction.nil? and self.name.nil?
    end # mutator direction=
    
    def name
      return nil unless self.has_name?
      @name.respond_to?(:slugify) ? @name.to_s : @location.to_s.snakify.split("_").map { |str| str.capitalize }.join(" ")
    end # accessor name
    
    def name=(name)  
      if name === true or name.nil?
        @name = name
      else
        validate_argument name, :as => "name", :respond_to? => :to_s
        @name = name.to_s
      end # if-elsif-else
    end # mutator name=
    
    def visible
      @enabled && @visible
    end # method visible
    
    def visible=(visible)
      @visible = !!visible
    end # mutator visible=
    
    def enabled=(enabled)
      @enabled = !!enabled
    end # mutator enabled=
    
    def description
      if @description
        return @description
      elsif self.has_direction? and self.has_name?
        return "#{self.direction} to #{self.name}"
      elsif self.has_direction?
        return "#{self.direction}"
      elsif self.has_name?
        return "to #{self.name}"
      else
        return nil
      end # if
    end # method description
    
    def description=(description)
      validate_argument description, :as => "description", :respond_to? => :to_s unless description.nil?
      @description = description.nil? ? nil : description.to_s
    end # method description=
    
    #################
    # Utility Methods
    
    def has_direction?
      !@direction.nil?
    end # method has_direction?
    
    def has_name?
      !@name.nil? or !self.has_direction?
    end # method has_name?    
  end # class Edge
end # module Explore::Models
