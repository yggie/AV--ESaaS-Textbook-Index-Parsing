require 'rexml/document'
require 'csv'

@index_items = []
@index_xref = []

def store(item)
  if item =~ /\d+/
    @index_items << {
      H0: pretty(@H0.texts),
      H1: @H1 ? pretty(@H1.texts) : nil,
      H2: @H2 ? pretty(@H2.texts) : nil,
      page: item.to_i,
      group: pretty(@group.texts),
      raw: (@H2 || @H1 || @H0).to_s
    }
  else
    @index_xref << {
      H0: pretty(@H0.texts),
      H1: @H1 ? pretty(@H1.texts) : nil,
      H2: @H2 ? pretty(@H2.texts) : nil,
      xref: item,
      raw: (@H2 || @H1 || @H0).to_s,
      group: pretty(@group.texts)
    }
  end
end

def pretty(texts)
  return if texts.nil?
  texts.join(' ')                 # join any separated texts
       .gsub(/,\s*$/, '')         # remove ending commas
       .gsub(/(^\s*|\s*$)/, '')   # remove trailing whitespaces
       .gsub(/\s+/, ' ')          # suppress multiple whitespaces
end

def parseElem(elem)
  case elem.name
  when 'H0'
    @H0 = elem
    @H1 = nil
    @H2 = nil

  when 'H1'
    @H1 = elem
    @H2 = nil

  when 'H2'
    @H2 = elem

  when 'GROUP'
    @group = elem
    @H0 = nil

  when 'INDEX'

  when 'XREF'
    store elem.text

  when 'PAGE'
    if elem.has_text?
      elem.text.split(',').each do |t|
        store t
      end
    end

  else
    puts elem
    raise Exception
  end

  elem.each_element do |es|
    parseElem es
  end
end

text = File.read("index.xml")
text.gsub!(/(<I>|<\/I>|<B>|<\/B>)/, '') # remove formatting <I> elements, which cause so much problems
text.gsub!(/(&ndash;)/, '-')             # remove html escaped characters
text.gsub!(/(&quot;)/, '"')
xml = REXML::Document.new(text);

xml.elements.each do |elem|
  parseElem elem
end

@index_items = @index_items.sort_by { |item| item[:page] }

# puts @index_items

CSV.open("output_index.csv", "wb") do |csv|
  csv << [ 'Group', 'H0', 'H1', 'H2', 'Page', 'Raw XML Line (stripped of <I> and <B>)' ]
  @index_items.each do |item|
    csv << [ item[:group], item[:H0], item[:H1], item[:H2], item[:page].to_s, "\"#{item[:raw]}\"" ]
  end
end

CSV.open("output_xref.csv", "wb") do |csv|
  csv << [ 'Group', 'H0', 'H1', 'H2', 'Page', 'Raw XML Line (stripped of <I> and <B>)' ]
  @index_xref.each do |xref|
    csv << [ xref[:group], xref[:H0], xref[:H1], xref[:H2], xref[:xref], "\"#{xref[:raw]}\"" ]
  end
end

