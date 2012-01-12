# lib/text_explorer/parsers/location_parser.rb

require 'util/argument_validator'
require 'text_explorer/parsers/delegate_parser'
require 'text_explorer/explore/location'

module TextExplorer::Parsers
  # A parser for the domain-specific language used to instantiate new location
  # instances. Separate from the location itself to avoid namespace collisions.
  class LocationParser
    include RoundTable::Util::ArgumentValidator
    include DelegateParser
    
    def initialize(location)
      validate_argument location, :as => "location",
        :type => TextExplorer::Explore::Location
      
      @delegate = location
    end # method initialize
    
    def condition(&block)
      raise ArgumentError.new "expected block" unless block_given?
      
      Proc.new &block
    end # method condition
    
    def description(value = nil, &block)
      raise ArgumentError.new "expected String or block" unless block_given? or value.is_a? String
      raise ArgumentError.new "expected value or block, but not both" if block_given? and !value.nil?
      @delegate.description = block_given? ? block : value
    end # method description
    
    def name(value)
      raise ArgumentError.new "expected String" unless value.is_a? String
      @delegate.name = value
    end # method name
    
    def go(name, params = {})
      validate_argument name, :as => :name, :type => [String, Symbol]
      
      @delegate.add_edge name.to_s, params
    end # method go
    
    def go_to(name, params = {})
      go name, params.update(:particle => true)
    end # method go_to
  end # class LocationParser
end # module MonsterCatcher::Explore
