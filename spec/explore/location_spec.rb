# spec/explore/location_spec.rb

require 'spec_helper'
require 'events/event_dispatcher'
require 'text_explorer/explore/location'
require 'text_explorer/explore/region'

describe TextExplorer::Explore::Location do
  include RoundTable::Events::EventDispatcher
  
  before :each do
    @region = mock('region')
    @region.stub(:is_a?) { |type| type == TextExplorer::Explore::Region }
    @region.stub(:slug) { :the_clouds }
    
    @slug = :cloud_nine
    @params = { :region => @region }
    @block = Proc.new do; end
    
    @name = "Cloud Nine"
    @description_as_string = "Cloud Nine is a magic city in the clouds."
    @description_as_block = Proc.new do "#{self.name} is a magic city in the clouds." end
  end # before :each
  
  describe "initialization" do
    describe "slug must be a string or symbol" do
      it { expect { described_class.new nil, @params }.to raise_error ArgumentError }
      it { expect { described_class.new @slug, @params }.not_to raise_error }
      it { expect { described_class.new @slug.to_s, @params }.not_to raise_error }
    end # describe slug ...
    
    describe "params must be a hash" do
      it { expect { described_class.new @slug, nil}.to raise_error ArgumentError }
      it { expect { described_class.new @slug, @params}.not_to raise_error }
      
      describe ":region must be a TextExplorer::Explore::Region" do
        it { expect { described_class.new @slug, @params.clone.update(:region => nil)}.to raise_error ArgumentError }
      end # describe :region ...
    end # describe params must be a hash
    
    describe "with block" do
      it { expect { described_class.new @slug, @params, &@block }.not_to raise_error ArgumentError }
    end # describe with block
  end # describe initialization
  
  context "(initialized without block)" do
    before :each do
      @location = described_class.new @slug, @params
    end # before :each
    subject { @location }
    
    describe "region property" do
      it { subject.region.should be @region }
      it { expect { subject.region = nil}.to raise_error ArgumentError }
      it { expect { subject.region = @region }.not_to raise_error }
      
      context "(changed)" do
        before :each do
          @region_alt = mock('region')
          @region_alt.stub(:is_a?) { |type| type == TextExplorer::Explore::Region }
          subject.region = @region_alt
        end # before_each
        
        it { subject.region.should be @region_alt }
      end # context (changed)
    end # describe region property
    
    describe "slug property" do
      it { subject.slug.should == @slug }
      it { expect { subject.slug = :this_should_fail }.to raise_error NoMethodError }
    end # describe slug property
    
    describe "name property" do
      it { subject.name.should == "Cloud Nine" }
      it { expect { subject.name = nil }.to raise_error ArgumentError }
      it { expect { subject.name = "Cloud Seven" }.not_to raise_error }
      
      context "(changed)" do
        before :each do
          @name = "Cloud Ten"
          subject.name = @name
        end # before :each
        
        it { subject.name.should == @name }
      end # context (changed)
    end # describe name property
    
    describe "description property" do
      it { subject.description.should be_a String }
      it { expect { subject.description = nil }.to raise_error ArgumentError }
      it { expect { subject.description = @description_as_string }.not_to raise_error }
      it { expect { subject.description = @description_as_block }.not_to raise_error }
      
      describe "initialized as string" do
        before :each do
          @params.update :description => @description_as_string
          @location = described_class.new @slug, @params
        end # before :each
        subject { @location }
        
        it { subject.description.should == @description_as_string }
      end # describe initialized as string
      
      describe "set as string" do
        before :each do
          @location.description = @description_as_string
        end # before :each
        subject { @location }
        
        it { subject.description.should == @description_as_string }
      end # describe set as string
      
      describe "initialized as block" do
        before :each do
          @params.update :description => @description_as_block
          @location = described_class.new @slug, @params
        end # before :each
        subject { @location }
        
        it { subject.description.should == @description_as_string }
      end # describe initialized as block
      
      describe "set as block" do
        before :each do
          @location.description = @description_as_block
        end # before :each
        subject { @location }
        
        it { subject.description.should == @description_as_string }
      end # describe set as block
    end # describe description property
    
    describe "locations" do
      before :each do
        @edge_name = "Cloud Ten"
        @edge_params = {
          :if => nil,
          :location => :cloud_ten,
          :particle => true,
          :region => :the_clouds,
          :unless => nil
        } # end edge_params
      end # before :each
      
      it { expect { subject.add_edge nil, @params }.to raise_error ArgumentError }

      it "name must be unique" do
        subject.add_edge @edge_name, @edge_params
        expect { subject.add_edge @edge_name, @edge_params }.to raise_error ArgumentError
      end # it name must be unique
      
      it { expect { subject.add_edge nil, @params.update(:if => true) }.to raise_error ArgumentError }
      it { expect { subject.add_edge nil, @params.update(:unless => false) }.to raise_error ArgumentError }
      
      context "(added)" do
        before :each do
          subject.add_edge @edge_name, @edge_params
          subject.add_edge "Hidden Through If", @edge_params.clone.update(:if => Proc.new { false })
          subject.add_edge "Hidden Through Unless", @edge_params.clone.update(:unless => Proc.new { true })
          subject.add_edge "Direction", @edge_params.clone.update(:particle => false)
        end # before :each
        
        %w(location particle region).each do |key|
          it { subject.edges[@edge_name][key].should == @edge_params[key] }
          it { subject.edges["Hidden Through If"][key].should == @edge_params[key] }
          it { subject.edges["Hidden Through Unless"][key].should == @edge_params[key] }
        end # each
        
        it { subject.edges["Direction"][:location].should == @edge_params[:location] }
        it { subject.edges["Direction"][:particle].should_not == @edge_params[:particle] }
        it { subject.edges["Direction"][:region].should == @edge_params[:region] }
        
        it { subject.has_edge?(@edge_name).should be true }
        it { subject.has_edge?("Hidden Through If").should be true }
        it { subject.has_edge?("Hidden Through Unless").should be true }
        it { subject.has_edge?("Direction").should be true }
        it { subject.has_edge?("No Such Edge").should be false }
        
        it { subject.has_location?(@edge_name).should be true }
        it { subject.has_location?("Hidden Through If").should be false }
        it { subject.has_location?("Hidden Through Unless").should be false }
        it { subject.has_location?("Direction").should be true }
        it { subject.has_location?("No Such Edge").should be false }
        
        it { subject.locations.should include @edge_name }
        it { subject.locations.should include "Direction" }
        it { subject.locations.should_not include "Hidden Through If" }
        it { subject.locations.should_not include "Hidden Through Unless" }
        it { subject.locations.should_not include "No Such Edge" }
      end # context (added)
    end # describe locations
  end # context initialized without block
  
  context "(initialized with block)" do
    before :each do
      @block = Proc.new do
        name "Cloud Eleven"
        description do "#{self.name} is a magic city in the clouds." end
        
        go "North", :region => :more_clouds
        go_to "Cloud Five", :if => condition { false }
        
        action :fly do
          self.puts "All it takes is faith and trust."
        end # action :fly
      end # Proc.new
      @location = described_class.new @slug, @params, &@block
    end # before :each
    subject { @location }
    
    describe "description property" do
      it { subject.description.should == @description_as_string.gsub(/nine/i, "Eleven") }
    end # describe description property
    
    describe "name property" do
      it { subject.name.should == @name.gsub(/nine/i, "Eleven") }
    end # describe name property
    
    describe "locations" do
      it { subject.has_edge?("North").should be true }
      it { subject.has_edge?("Cloud Five").should be true }
      
      it { subject.has_location?("North").should be true }
      it { subject.has_location?("Cloud Five").should be false }
      
      it { subject.locations.should include "North" }
      it { subject.locations.should_not include "Cloud Five" }
      
      it { subject.edges["North"][:region].should be :more_clouds }
      it { subject.edges["North"][:particle].should be nil }
      
      it { subject.edges["Cloud Five"][:region].should be :the_clouds }
      it { subject.edges["Cloud Five"][:particle].should be true }
    end # describe locations
    
    describe "actions" do
      it { subject.list_own_actions.should include "fly" }
      it { subject.has_action?(:fly).should be true }
      it "executes actions" do
        output = nil
        subject.add_listener :text_output, Proc.new { |event|
          output = event[:text]
        } # end listener :text_output
        subject.execute_action :fly
        
        output.should =~ /faith and trust/i
      end # it executes actions
    end # describe actions
  end # context initialized with block
end # describe Location
