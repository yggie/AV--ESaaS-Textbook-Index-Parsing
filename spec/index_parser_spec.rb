# spec/your_class_spec.rb
require 'spec_helper'
require 'index_parser.rb'
# require '../lib/'

describe 'Parser' do
  before :each do
    parser = new Parser
  end

  it 'should assign index_items' do
    parser '<root><node><item>content</item></node><empty_node/></root>'
    expect(assign: @index_items).to_not be_nil
  end
end