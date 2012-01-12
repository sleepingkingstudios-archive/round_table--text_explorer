# spec/parsers/location_parser_spec.rb

require 'spec_helper'
require 'parsers/delegate_parser_helper'
require 'text_explorer/explore/location'
require 'text_explorer/parsers/location_parser'

describe TextExplorer::Parsers::LocationParser do
  before :each do
    @location = mock('location')
    @location.stub :is_a? do |type| type == TextExplorer::Explore::Location end
  end # before :each
  
  describe "initialization" do
    describe "location must be a Location" do
      it { expect { described_class.new }.to raise_error ArgumentError }
      it { expect { described_class.new nil }.to raise_error ArgumentError }
      it { expect { described_class.new @location }.not_to raise_error }
    end # describe location must be a Location
  end # describe initialization
  
  context "(initialized)" do
    before :each do
      @parser = described_class.new @location
    end # before :each
    subject { @parser }
    
    it_behaves_like "a DelegateParser"
    
    describe "condition" do
      it "does not take any arguments" do
        expect {
          subject.instance_eval do
            condition nil do; end
          end # instance_eval
        }.to raise_error ArgumentError
      end # it does not take any arguments
      
      it "must take a block" do
        expect {
          subject.instance_eval do
            condition
          end # instance_eval
        }.to raise_error ArgumentError
      end # it must take a block
      
      it "returns a Proc" do
        subject.instance_eval {
          condition do; end
        }.should be_a Proc
      end # it returns a Proc
    end # describe condition
    
    describe "description" do
      before :each do
        @description_as_string = "A maze of twisty passages, all alike."
      end # before :each
      
      it "must be a String or block" do
        expect {
          subject.instance_eval do
            description nil
          end # instance_eval
        }.to raise_error ArgumentError
      end # it must be a String or block
      
      it "can be a String" do
        @location.should_receive(:description=).with(@description_as_string)
        subject.instance_eval do
          description "A maze of twisty passages, all alike."
        end # instance_eval
      end # it can be a String
      
      it "can be a block" do
        @location.should_receive(:description=).with(kind_of Proc)
        subject.instance_eval do
          description do; "A twisty maze of passages, all alike." end
        end # instance_eval
      end # it can be a block
      
      it "cannot be a String and a block" do
        expect {
          subject.instance_eval do
            description "This should fail." do; end
          end # instance_eval
        }.to raise_error ArgumentError
      end # it cannot be both a String and a block
    end # describe description
    
    describe "name" do
      before :each do
        @name = "Caverns of Mystery"
      end # before :each
      
      it "must be a String" do
        expect {
          subject.instance_eval do
            name nil
          end # instance_eval
        }.to raise_error ArgumentError
      end # it must be a String
      
      it "can be a String" do
        @location.should_receive(:name=).with(@name)
        subject.instance_eval do
          name "Caverns of Mystery"
        end # instance_eval
      end # it can be a String
    end # describe "name"
    
    describe "go" do
      before :each do
        @edge_name = "Mysterious Cavern"
        @edge_params = {
          :continent => :the_ground,
          :if => nil,
          :location => :mysterious_cavern,
          :particle => false,
          :region => :the_caverns,
          :unless => nil
        } # end edge_params
      end # before :each
      
      it "name must be a String" do
        expect {
          subject.instance_eval do
            go nil
          end # instance_eval
        }.to raise_error ArgumentError
      end # it name must be a String
      
      it "takes a name and optional params" do
        @location.should_receive(:add_edge).with(@edge_name, @edge_params)
        subject.instance_eval do
          go "Mysterious Cavern",
            :continent => :the_ground,
            :if => nil,
            :location => :mysterious_cavern,
            :particle => false,
            :region => :the_caverns,
            :unless => nil
        end # instance_eval
      end # it takes a name and ...
    end # describe go
    
    describe "go_to" do
      before :each do
        @edge_name = "Mysterious Cavern"
        @edge_params = {
          :continent => :the_ground,
          :if => nil,
          :location => :mysterious_cavern,
          :particle => false,
          :region => :the_caverns,
          :unless => nil
        } # end edge_params
      end # before :each
      
      it "aliases go, with :particle => true" do
        @parser.should_receive(:go).with(@edge_name, @edge_params.clone.update(:particle => true))
        subject.instance_eval do
          go_to "Mysterious Cavern",
            :continent => :the_ground,
            :if => nil,
            :location => :mysterious_cavern,
            :particle => false,
            :region => :the_caverns,
            :unless => nil
        end # subject.instance_eval
      end # it aliases go ...
    end # describe go_to
  end # context (initialized)
end # describe LocationParser
