# spec/parsers/delegate_parser_spec.rb

require 'spec_helper'
require 'parsers/delegate_parser_helper'
require 'explore/parsers/delegate_parser'

module Explore::Mock # :nodoc: all
  module Parsers
    class MockDelegateParser
      include Explore::Parsers::DelegateParser
      
      def initialize(delegate)
        @delegate = delegate
      end # constructor initialize
    end # class MockDelegateParser
  end # module Parsers
end # module TextExplorer::Mock

describe Explore::Parsers::DelegateParser do
  let(:delegate) {
    delegate = mock('delegate')
  } # end let :delegate
  
  let(:described_class) { Explore::Mock::Parsers::MockDelegateParser }
  
  context "(initialized)" do
    before :each do
      @parser = described_class.new delegate
    end # before :eachs
    subject { @parser }
    
    it_behaves_like "a DelegateParser"
  end # context (initialized)
end # describe Explore::Parsers::DelegateParser