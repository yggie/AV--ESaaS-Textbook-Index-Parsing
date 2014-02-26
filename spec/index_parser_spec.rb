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
    expect(parser.index_items[0]).to eq({H0: "Accessor method, Ruby objects", B: false, H1: nil, H2: nil, page: 79, group: "", :I => false, raw: "<H0>Accessor method, Ruby objects, <PAGE>79</PAGE></H0>", :latex => %q{\index{Accessor method, Ruby objects}}})
  end

  it 'should assign multiple index items with a page number under the same heading' do
    parser.parse '<INDEX><GROUP><H0>ABC score</H0>
<H1>definition, <PAGE>310</PAGE></H1><H1>example, <PAGE><I>310</I></PAGE></H1></GROUP></INDEX>'
    expect(assign: @index_items).to_not be_nil
    expect(parser.index_items[0]).to eq({:H0 => "ABC score", B: false, :H1 => "definition", :H2 => nil, :page => 310, :group => "", :I => false, :raw => "<H1>definition, <PAGE>310</PAGE></H1>", :latex => %q{\index{ABC score!definition}}})
    expect(parser.index_items[1]).to eq({:H0 => "ABC score", :H1 => "example", :H2 => nil, :page => 310, B: false, :group => "", :I => true, :raw => "<H1>example, <PAGE><I>310</I></PAGE></H1>", :latex => %q{\index{ABC score!example|textit}}})
  end

  it 'should handle H2 elements' do
    parser.parse '<INDEX><GROUP><B>F</B><H0>Framework concepts</H0><H1>JavaScript</H1><H2>client-side, <PAGE><B>169</B></PAGE></H2></GROUP></INDEX>'
    expect(assign: @index_items).to_not be_nil
    expect(parser.index_items.count).to eq 1
    expect(parser.index_items[0]).to eq H0: 'Framework concepts', H1: 'JavaScript', H2: 'client-side', :page => 169, group: 'F', I: false, B: true, :raw => "<H2>client-side, <PAGE><B>169</B></PAGE></H2>", latex: '\\index{Framework concepts!JavaScript!client-side|textbf}'
  end

  context 'page numbers are styled for figures (italics) and tables (bold)' do
    it 'should assign an index item with a page number and italics' do
      parser.parse '<INDEX><GROUP><H0>ActiveModel, validation, <PAGE><I>137</I></PAGE></H0></GROUP></INDEX>'
      expect(assign: @index_items).to_not be_nil
      expect(parser.index_items[0]).to eq({:H0 => "ActiveModel, validation", :H1 => nil, :H2 => nil, :page => 137, :group => "", :I => true, B: false, :raw => "<H0>ActiveModel, validation, <PAGE><I>137</I></PAGE></H0>", :latex => %q{\index{ActiveModel, validation|textit}}})
    end

    it 'should assign an index item with a page number in bold' do
      parser.parse '<INDEX><GROUP><H0>ActiveModel, validation, <PAGE><B>137</B></PAGE></H0></GROUP></INDEX>'
      expect(assign: @index_items).to_not be_nil
      expect(parser.index_items[0]).to eq({:H0 => "ActiveModel, validation", :H1 => nil, :H2 => nil, :page => 137, :group => "",:I => false, :B => true, :raw => "<H0>ActiveModel, validation, <PAGE><B>137</B></PAGE></H0>", :latex => %q{\index{ActiveModel, validation|textbf}}})
    end
  end

  it 'should handle italics in index entries' do
    parser.parse '<INDEX><GROUP><H0>Amazon</H0><H1>SOA <I>vs.</I> siloed software, <PAGE>7</PAGE></H1></GROUP></INDEX>'
    expect(assign: @index_items).to_not be_nil
    expect(parser.index_items[0]).to eq({:H0 => "Amazon", :H1 => "SOA siloed software", :H2 => nil, :page => 7, :group => "", :I => false, :B => false, :raw => "<H1>SOA <I>vs.</I> siloed software, <PAGE>7</PAGE></H1>", :latex => %q{\index{Amazon!SOA \textit{vs.} siloed software}}})
  end

  it "should handle cross references with 'see'" do
    parser.parse '<INDEX><GROUP><H0>AJAX, <XREF><I>see</I> Asynchronous JavaScript And XML (AJAX)</XREF></H0></GROUP></INDEX>'
    expect(assign: @index_items).to_not be_nil
    expect(parser.index_xref[0]).to eq({:H0 => "AJAX", :H1 => nil, :H2 => nil, :xref => "Asynchronous JavaScript And XML (AJAX)", :group => "", :raw => "<H0>AJAX, <XREF><I>see</I> Asynchronous JavaScript And XML (AJAX)</XREF></H0>", :latex => %q{\index{AJAX|see{Asynchronous JavaScript And XML (AJAX)}}}})
  end

  it "should handle cross references with 'see also'" do
    parser.parse '<INDEX><GROUP><H0>AJAX, <XREF><I>see also</I> Asynchronous JavaScript And XML (AJAX)</XREF></H0></GROUP></INDEX>'
    expect(assign: @index_items).to_not be_nil
    expect(parser.index_xref[0]).to eq({:H0 => "AJAX", :H1 => nil, :H2 => nil, :xref => "Asynchronous JavaScript And XML (AJAX)", :group => "", :raw => "<H0>AJAX, <XREF><I>see also</I> Asynchronous JavaScript And XML (AJAX)</XREF></H0>", :latex => %q{\index{AJAX|seealso{Asynchronous JavaScript And XML (AJAX)}}}})
  end


end
