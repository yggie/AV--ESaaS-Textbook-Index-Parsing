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
    expect(parser.H0).to_not be_nil
  end

  it 'should assign index_items even with bold in ' do
    parser.parse '<INDEX><GROUP><B>A</B></GROUP></INDEX>'
    expect(assign: @index_items).to_not be_nil
    expect(parser.group.text).to eq 'A'
  end

  it 'should assign an index item with a page number' do
    parser.parse '<INDEX><GROUP><H0>Accessor method, Ruby objects, <PAGE>79</PAGE></H0></GROUP></INDEX>'
    expect(assign: @index_items).to_not be_nil
    expect(parser.index_items[0]).to eq({H0: "Accessor methodRuby objects", H1: nil, H2:nil, page:79, group:"", :I=>false, raw:"<H0>Accessor method, Ruby objects, <PAGE>79</PAGE></H0>"})
  end

  it 'should assign multiple index items with a page number under the same heading' do
    parser.parse '<INDEX><GROUP><H0>ABC score</H0>
<H1>definition, <PAGE>310</PAGE></H1><H1>example, <PAGE><I>310</I></PAGE></H1></GROUP></INDEX>'
    expect(assign: @index_items).to_not be_nil
    expect(parser.index_items[0]).to eq({:H0=>"ABC score", :H1=>"definition", :H2=>nil, :page=>310, :group=>"", :I=>false, :raw=>"<H1>definition, <PAGE>310</PAGE></H1>"})
    expect(parser.index_items[1]).to eq({:H0=>"ABC score", :H1=>"example", :H2=>nil, :page=>310, :group=>"", :I=>true, :raw=>"<H1>example, <PAGE><I>310</I></PAGE></H1>"})
  end

  it 'should assign an index item with a page number and italics' do
    parser.parse '<INDEX><GROUP><H0>ActiveModel, validation, <PAGE><I>137</I></PAGE></H0></GROUP></INDEX>'
    expect(assign: @index_items).to_not be_nil
    expect(parser.index_items[0]).to eq({:H0=>"ActiveModelvalidation", :H1=>nil, :H2=>nil, :page=>137, :group=>"", :I=>true, :raw=>"<H0>ActiveModel, validation, <PAGE><I>137</I></PAGE></H0>"})
  end


end
