# spec/explore/location_spec.rb

require 'spec_helper'
require 'fixtures/models/edges'
require 'fixtures/models/locations'

require 'events/event_dispatcher'
require 'explore/models/location'
require 'explore/models/region'

describe Explore::Models::Location do
  include RoundTable::Events::EventDispatcher
  
  let :fixtures do Explore::Fixtures[:locations] end
  
  describe "initialization" do
    let :fixture do fixtures[:mushroom_kingdom] end
    
    describe "slug must be a string or symbol" do
      it { expect { described_class.new nil, fixture.params }.to raise_error ArgumentError }
      it { expect { described_class.new fixture.slug, fixture.params }.not_to raise_error }
      it { expect { described_class.new fixture.slug.to_s, fixture.params }.not_to raise_error }
    end # describe slug ...
    
    describe "params must be a hash or nil" do
      it { expect { described_class.new fixture.slug, :symbol}.to raise_error ArgumentError }
      it { expect { described_class.new fixture.slug }.not_to raise_error }
      it { expect { described_class.new fixture.slug, nil }.not_to raise_error }
      it { expect { described_class.new fixture.slug, fixture.params }.not_to raise_error }
    end # describe params must be a hash
    
    describe "with block" do
      it { expect { described_class.new fixture.slug, fixture.params, &fixture.block }.not_to raise_error ArgumentError }
    end # describe with block
  end # describe initialization
  
  context "(initialized without block)" do
    let :fixture do fixtures[:mushroom_kingdom] end
    subject do described_class.new fixture.slug, fixture.params end
    
    describe "region property" do
      let :region do
        region = mock('region')
        region.stub(:is_a?) { |type| type == Explore::Models::Region }
        region.stub(:slug) { :mushroom_kingdom }
        region
      end # end let
      
      it { subject.region.should be nil }
      it { expect { subject.region = nil}.to raise_error ArgumentError }
      it { expect { subject.region = region }.not_to raise_error }
      
      context "(changed)" do
        before :each do subject.region = region end
        
        it { subject.region.should be region }
      end # context (changed)
    end # describe region property
    
    describe "slug property" do
      it { subject.slug.should == fixture.slug }
      it { expect { subject.slug = :this_should_fail }.to raise_error NoMethodError }
    end # describe slug property
    
    describe "name property" do
      let :name do "Kero Sewers" end
      
      it { subject.name.should == fixture.slug.to_s.split("_").map { |str| str.capitalize }.join(" ") }
      it { expect { subject.name = nil }.to raise_error ArgumentError }
      it { expect { subject.name = name }.not_to raise_error }
      
      context "(changed)" do
        before :each do subject.name = name end
        
        it { subject.name.should == name }
      end # context (changed)
    end # describe name property
    
    describe "description property" do
      let :description_as_string do "Mushroom Kingdom is ruled by the mercurial Princess Toadstool." end
      let :description_as_proc do Proc.new { "#{self.name} is ruled by the mercurial Princess Toadstool." } end
      
      it { subject.description.should be_a String }
      it { expect { subject.description = nil }.to raise_error ArgumentError }
      it { expect { subject.description = description_as_string }.not_to raise_error }
      it { expect { subject.description = description_as_proc }.not_to raise_error }
      
      describe "initialized as string" do
        subject { described_class.new fixture.slug, fixture.params.dup.update({ :description => description_as_string }) }
        
        it { subject.description.should == description_as_string }
      end # describe initialized as string
      
      describe "set as string" do
        before :each do subject.description = description_as_string end;
        
        it { subject.description.should == description_as_string }
      end # describe set as string
      
      describe "initialized as block" do
        subject { described_class.new fixture.slug, fixture.params.dup.update({ :description => description_as_proc }) }
        
        it { subject.description.should == description_as_string }
      end # describe initialized as block
      
      describe "set as block" do
        before :each do subject.description = description_as_proc end;
        
        it { subject.description.should == description_as_string }
      end # describe set as block
    end # describe description property
    
    describe "edges" do
      def self.edge_data
        Explore::Fixtures[:edges].values
      end # class macro edge_data
      
      let(:edge_data) { self.class.edge_data }
      
      it { expect { subject.add_edge }.to raise_error ArgumentError, /wrong number of arguments/i }
      it { expect { subject.add_edge nil }.to raise_error, /location not to be nil/i }
      it { expect { subject.add_edge edge_data.first[:location] }.not_to raise_error }
      it { expect { subject.add_edge edge_data.first[:location], edge_data.first[:params] }.not_to raise_error }

      context "(added one)" do
        let(:location_name) {
          edge_data.first[:location].to_s.snakify.split("_").map{ |str| str.capitalize }.join(" ")
        } # end let :location_name
        
        before :each do
          subject.add_edge edge_data.first[:location], edge_data.first[:params]
        end # before :each
        
        it { subject.should have_edge edge_data.first[:location] }
        it { subject.edges.should include edge_data.first[:location] }
        
        it { subject.should have_location location_name }
        it { subject.locations.should include location_name }
        
        describe "updating" do
          let(:params) {
            { :visible => false,
              :region => :kero_wetlands
            } # end anonymous Hash
          } # end let :params_update
          
          let(:edge) { subject.edges[edge_data.first[:location]] }
          
          before :each do
            @added_edge = subject.edges[edge_data.first[:location]]
            subject.add_edge edge_data.first[:location], params
          end # before :each
          
          it { subject.edges[edge_data.first[:location]].should be @added_edge }
          it "should update the edge" do
            params.each do |key, value|
              @added_edge.send(key).should == value
            end # each
          end # it should update the edge
        end # describe updating
      end # context (added one)

      context "(added many)" do
        before :each do
          edge_data.each do |data|
            subject.add_edge data[:location], data[:params]
          end # each
        end # before :each
        
        edge_data.each do |data_item|
          context do
            let(:data) { data_item }
          
            it { subject.should have_edge data[:location] }
            it { subject.should have_direction data[:params][:direction].to_s if data[:params][:direction] }
            it { subject.directions.values.should_not include data[:location] unless data[:params][:direction] }
          
            let(:name) {
              name = (data[:params][:name] if data[:params][:name].is_a? String) ||
               (data[:location].to_s.snakify.split("_").map { |str| str.capitalize }.join(" ") if data[:params][:direction] and data[:params][:name]) ||
               (data[:location].to_s.snakify.split("_").map { |str| str.capitalize }.join(" ") unless data[:params][:direction])
            } # end let :name
            
            it { subject.should have_location name if name }
            it { subject.locations.should include name => data[:location] if name }
            it { subject.locations.values.should_not include data[:location] unless name }
          end # anonymous context
        end # each
      end # context (added many)
    end # describe edges
  end # context initialized without block
  
  context "initialized with block" do
    let :fixture do fixtures[:mushroom_kingdom] end
    
    subject { described_class.new fixture.slug, fixture.params, &fixture.block }
    
    it { puts subject.inspect }
  end # context initialized with block
end # describe Location
