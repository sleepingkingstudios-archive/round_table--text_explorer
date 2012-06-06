# spec/fixtures/fixtures.rb

module Explore
  module Fixtures
    class << self
      def all
        return @@fixtures ||= {}
      end # class method all
      
      def find(key)
        return self[key]
      end # class method find
      
      def [](key)
        return (@@fixtures ||= {})[key] ||= {}
      end # class method []
    end # class << self
    
    class Fixture
      def initialize(klass, key, *args, &block)
        @klass = klass
        @key   = key
        @args  = args || []
        @block = block
        
        @instance = nil
      end # method initialize
      
      attr_reader :klass, :key, :args, :block
      
      def build
        return @instance || klass.new(*args, &block)
      end # method build
      
      def [](key)
        self.instance_variable_get(:"@#{key}") || self.send(key)
      end # method key
    end # class Fixture
  end # class Fixtures
end # module Explore
