# lib/explore/parsers/delegate_parser.rb

require 'controllers/action_delegate'
require 'util/argument_validator'

module Explore::Parsers
  # A general parser for the domain-specific language used to instantiate new
  # location instances. The delegate parser includes syntax for defining
  # actions and declaring delegates.
  module DelegateParser
    include RoundTable::Util::ArgumentValidator
    
    def action(name, &block)
      validate_argument name, :as => "name", :type => [String, Symbol]
      validate_argument @delegate, :as => "delegate",
        :respond_to? => :define_singleton_action
      raise ArgumentError.new "expected block" unless block_given?
      
      @delegate.define_singleton_action name, &block
    end # method action
  end # module DelegateParser
end # module Explore::Parsers
