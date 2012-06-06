# spec/models/region_spec.rb

require 'spec_helper'
require 'fixtures/models/regions'
require 'explore/models/region'

describe Explore::Models::Region do
  include Explore::Models
  
  let(:described_class) do Explore::Models::Region end
  let(:fixture) do Explore::Fixtures[:regions][:mushroom_kingdom] end
  
  describe "initialization" do
    describe "requires 1..2 arguments" do
      it { expect { described_class.new }.to raise_error ArgumentError,
        /wrong number of arguments/i }
      it { expect { described_class.new :foo, :bar, :baz }.to raise_error ArgumentError,
        /wrong number of arguments/i }
    end # describe requires a slug
    
    describe "requires a slug" do
      it { expect { described_class.new nil }.to raise_error ArgumentError,
        /not to be nil/i }
      it { expect { described_class.new [] }.to raise_error ArgumentError,
        /string or symbol/i }
        
      it { expect { described_class.new fixture.slug }.not_to raise_error }
    end # describe requires a slug
    
    describe "params must be hash or nil" do
      it { expect { described_class.new fixture.slug, :xyzzy }.to raise_error ArgumentError }
    end # describe params must be hash or nil
    
    describe "initializes with a slug and params" do
      it { expect { described_class.new fixture.slug, nil }.not_to raise_error ArgumentError }
      it { expect { described_class.new fixture.slug, fixture.params }.not_to raise_error }
    end # describe initializes with a slug and params
  end # describe initialization
  
  context "initialized" do
    let(:region) { fixture.build }
    
    describe "name" do
      it { region.should respond_to :name }
      it { region.name.should == fixture.params[:name] }
    end # describe name
    
    describe "slug" do
      it { region.should respond_to :slug }
      it { region.slug.should == fixture.slug }
    end # describe slug
    
    describe "locations" do
      let :location_slug do :throne_room end
      
      before :each do
        @location = mock('location')
        @location.stub :slug do location_slug end
        @location.stub :is_a? do |type| type == Explore::Models::Location end
      end # before :each
      let :location do @location end
      
      it { region.should respond_to :locations }
      it { region.locations.should == {} }
      
      describe "introspecting locations" do
        it { expect { region.has_location }.to raise_error ArgumentError, /wrong number of arguments/i }
        it { expect { region.has_location nil }.to raise_error ArgumentError, /not to be nil/i }
        it { expect { region.has_location "string" }.to raise_error ArgumentError, /expected location to be/i }
        it { region.has_location(location_slug).should be false }
      end # describe introspecting locations
      
      describe "adding locations" do
        it { expect { region.add_location }.to raise_error ArgumentError, /wrong number of arguments/i }
        it { expect { region.add_location nil }.to raise_error ArgumentError, /not to be nil/i }
        it { expect { region.add_location :symbol }.to raise_error ArgumentError, /expected location to be/i }
        it { expect { region.add_location location }.not_to raise_error }
        
        it { region.locations[location_slug].should be nil }
        it { region.has_location(location).should be false }
        it { region.has_location(location_slug).should be false }
        
        context "added" do
          before :each do
            region.add_location location
          end # before :each
          
          it { region.locations[location_slug].should be location }
          it { expect { region.add_location location }.to raise_error ArgumentError, /already exists/i }
          it { expect { region.add_location location, true }.not_to raise_error }
          
          it { region.has_location(location).should be true }
          it { region.has_location(location_slug).should be true }
        end # context added
      end # describe adding locations
      
      describe "building locations" do
        
      end # describe building locations
    end # describe locations
  end # context initialized
end # describe Region
