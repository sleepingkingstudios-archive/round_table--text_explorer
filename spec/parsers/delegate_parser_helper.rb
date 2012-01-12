# spec/parsers/delegate_parser_helper.rb

require 'spec_helper'
require 'controllers/action_delegate'
require 'text_explorer/parsers/delegate_parser'

shared_examples "a DelegateParser" do
  it { subject.should be_a TextExplorer::Parsers::DelegateParser }
  
  describe "action" do
    before :each do
      @action_name = :defenestrate
    end # before :each
    
    it "must have a name" do
      expect {
        subject.instance_eval do
          action do; end
        end # instance_eval
      }.to raise_error ArgumentError
    end # it must have a name
    
    it "name can be a String" do
      subject.instance_variable_get(:@delegate).should_receive(:define_singleton_action).with(@action_name.to_s)
      expect {
        subject.instance_eval do
          action "defenestrate" do; end
        end # instance_eval
      }.not_to raise_error
    end # it name must be a String
    
    it "name can be a Symbol" do
      subject.instance_variable_get(:@delegate).should_receive(:define_singleton_action).with(@action_name)
      expect {
        subject.instance_eval do
          action :defenestrate do; end
        end # instance_eval
      }.not_to raise_error
    end # it name must be a Symbol
    
    it "must have a block" do
      expect {
        subject.instance_eval do
          action @action_name
        end # instance_eval
      }.to raise_error ArgumentError
    end # it must have a block
  end # describe action
end # shared_examples a DelegateParser
