# spec/your_class_spec.rb
require 'spec_helper'
require 'index_parser.rb'
# require '../lib/'

describe 'Parser' do
  before :each do
    @parser = Parser.new
  end

  let(:parser) { @parser }

  it 'should assign index_items' do
    parser.parse '<INDEX><GROUP><H0>content</H0></GROUP></INDEX>'
    expect(assign: @index_items).to_not be_nil
  end
end
