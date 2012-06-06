# spec/explore/edge_spec.rb

require 'spec_helper'
require 'fixtures/models/edges'

require 'explore/models/edge'
require 'explore/models/location'

describe Explore::Models::Edge do
  let(:source) {
    source = mock('location')
    source.tap { |obj| obj.stub :is_a? do |type| type == Explore::Models::Location end }
  } # end let :source
  let(:location) { :location_name }
  let(:region) { :region_name }
  let(:direction) { :direction_name }
  let(:name) { "Name String" }
  let(:description) { "Description String" }
  
  let(:params) { Hash.new }
  
  describe "initialization" do
    it { expect { described_class.new }.to raise_error ArgumentError, /wrong number of arguments/i }
    
    it { expect { described_class.new nil }.to raise_error ArgumentError, /location not to be nil/i }
    it { expect { described_class.new ["ary"] }.to raise_error ArgumentError, /location to respond to :slugify/i }
    it { expect { described_class.new location }.not_to raise_error }
    
    it { expect { described_class.new location, nil }.to raise_error ArgumentError, /params not to be nil/i }
    it { expect { described_class.new location, :sym }.to raise_error ArgumentError, /params to respond to :keys/i }
    it { expect { described_class.new location, params }.not_to raise_error }

    it "should forward params to update(), with omitted values set to nil" do
      params.update( :region => region, :name => name )
      
      config = Hash.new
      %w(location region direction name description).each do |key| config[key.intern] = nil end
      %w(enabled visible).each do |key| config[key.intern] = true end
      config.update(params)
      config.update( :location => location )
      
      subject = described_class.allocate
      subject.should_receive(:update).with(config)
      subject.send :initialize, location, params
    end # it should forward params to update() ...
  end # describe initialization
  
  context "(initialized)" do
    let(:new_location) { :new_location }
    let(:new_region) { :new_region }
    let(:new_direction) { "New Direction" }
    let(:new_name) { "New Name" }
    let(:new_description) { "New Description" }
    
    before :each do
      @edge = described_class.new location
    end # before :each
    subject { @edge }
    
    describe "location property" do
      it { subject.location.should be location }

      it { expect { subject.location = nil }.to raise_error ArgumentError, /location not to be nil/i }
      it { expect { subject.location = ["ary"] }.to raise_error ArgumentError, /location to respond to :slugify/i }
      it { expect { subject.location = new_location }.not_to raise_error }
      
      context "(set)" do
        before :each do
          subject.location = new_location
        end # before :each
        
        it { subject.location.should be new_location }
      end # context (set)
    end # describe location property

    describe "region property" do
      it { subject.region.should be nil }
      it { expect { subject.region = nil }.not_to raise_error }
      it { expect { subject.region = new_region }.not_to raise_error }
      it { expect { subject.region = ["ary"] }.to raise_error ArgumentError, /region to respond to :slugify/i }
      
      context "(set)" do
        before :each do
          subject.region = new_region
        end # before :each
        
        it { subject.region.should be new_region }
      end # context (set)
    end # describe region property
    
    describe "direction property" do
      it { subject.should_not have_direction }
      
      it { subject.direction.should be nil }
      it { expect { subject.direction = nil }.not_to raise_error }
      it { expect { subject.direction = new_direction }.not_to raise_error }
      
      context "(set)" do
        before :each do
          subject.direction = new_direction
        end # before :each
        
        it { subject.should have_direction }
        it { subject.direction.should be new_direction }
        
        describe "description property" do
          it { subject.description.should == "#{subject.direction}" }
        end # describe description property
      end # context (set)
    end # describe direction property
    
    describe "name property" do
      it { subject.should have_name }
      it { subject.name.should eq location.to_s.snakify.split("_").map { |str| str.capitalize }.join(" ") }
      it { expect { subject.name = nil }.not_to raise_error }
      it { expect { subject.name = new_name }.not_to raise_error }
      
      context "(set)" do
        before :each do
          subject.name = new_name
        end # before :each
        
        it { subject.should have_name }
        it { subject.name.should be new_name }
        
        describe "description property" do
          it { subject.description.should == "to #{subject.name}" }
        end # describe description property
      end # context (set)
      
      context "(set to nil)" do
        before :each do subject.name = nil; end
        
        it { subject.should have_name }
        it { subject.name.should be == location.to_s.snakify.split("_").map { |str| str.capitalize }.join(" ") }
      end # context (set to nil)
      
      context "(set to nil with direction)" do
        before :each do
          subject.name = nil
          subject.direction = "second star to the right"
        end # before :each
        
        it { subject.should_not have_name }
        it { subject.name.should be nil }
      end # context (set to nil with direction)
    end # describe name property
    
    describe "description property" do
      it { subject.description.should == "to #{subject.name}" }
      it { expect { subject.description = nil }.not_to raise_error }
      it { expect { subject.description = new_description }.not_to raise_error }
      
      context "(set)" do
        before :each do
          subject.description = new_description
        end # before :each
        
        it { subject.description.should == new_description }
      end # context (set)
    end # describe description property
    
    describe "enabled property" do
      it { subject.enabled.should be true }
      it { expect { subject.enabled = false }.not_to raise_error }
      
      context "(set)" do
        before :each do
          subject.enabled = false
        end # before :each
        
        it { subject.enabled.should be false }
        it { subject.visible.should be false }
      end # context (set)
    end # describe enabled property
    
    describe "visible property" do
      it { subject.visible.should be true }
      it { expect { subject.visible = false }.not_to raise_error }
      
      context "(set)" do
        before :each do
          subject.visible = false
        end # before :each
        
        it { subject.visible.should be false }
      end # context (set)
    end # describe visible property
    
    describe "update method" do
      let(:new_params) do
        { :location => new_location,
          :region => new_region,
          :direction => new_direction,
          :name => new_name,
          :description => new_description
        } # end anonymous Hash
      end # let :new_params
      
      it { expect { subject.update new_params }.not_to raise_error }
      
      it "should call property mutators" do
        subject.should_receive(:location=).with(new_location)
        subject.should_receive(:region=).with(new_region)
        subject.should_receive(:direction=).with(new_direction)
        subject.should_receive(:name=).with(new_name)
        subject.should_receive(:description=).with(new_description)
        
        subject.update(new_params)
      end # it should call property mutators
    end # describe update method
  end # context (initialized)
end # describe Edge
