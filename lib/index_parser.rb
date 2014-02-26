require 'rexml/document'
require 'csv'
require 'debugger'

class Parser

  attr_accessor :index_items, :index_xref, :H0, :H1, :H2, :group

  def initialize
    @index_items = []
    @index_xref = []
    @H0 = nil
    @H1 = nil
    @H2 = nil
    @xref = nil
    @group = nil
  end

  def create_xref_latex(item)
    latex = "\\index{#{pretty(@H0.texts)}"
    latex += '|'
    puts  @xref.text if @xref
    latex +=  @xref.children[0].text.delete ' ' if @xref
    latex += '{'
    latex += item
    latex += '}}'
    latex
  end

  def create_latex(italic, bold)
    latex = "\\index{#{pretty(@H0.texts)}"
    latex += "!#{get_text_with_latex_formatting(@H1)}" unless @H1.nil?
    latex += "!#{get_text_with_latex_formatting(@H2)}" unless @H2.nil?
    latex += '|textit' if italic
    latex += '|textbf' if bold
    latex += '}'
    latex
  end

  def get_text_with_latex_formatting(elem)
    raw = elem.children.join {|e| e.to_s}
    rgx = /^(.*), <PAGE>(<(I|B)>)?\d+(<\/(I|B)>)?<\/PAGE>/.match(raw)
    return pretty(elem.texts) if rgx.nil?
    stem = rgx[1]
    italics_sorted = stem.sub('<I>','\textit{')
    italics_sorted = italics_sorted.sub('</I>','}')
    italics_sorted.nil? ? stem : italics_sorted
  end

  def store_xref(item)
    @index_xref << {
        H0: pretty(@H0.texts),
        H1: @H1 ? pretty(@H1.texts) : nil,
        H2: @H2 ? pretty(@H2.texts) : nil,
        xref: item.strip,
        latex: create_xref_latex(item.strip),
        raw: (@H2 || @H1 || @H0).to_s,
        group: pretty(@group.texts)
    }
  end

  def store(item, italic = false, bold = false)
      @index_items << {
          H0: pretty(@H0.texts),
          H1: @H1 ? pretty(@H1.texts) : nil,
          H2: @H2 ? pretty(@H2.texts) : nil,
          latex: create_latex(italic, bold),
          page: item =~ /\d/ ? item.to_i : -1,
          group: pretty(@group.texts),
          raw: (@H2 || @H1 || @H0).to_s,
          I: italic,
          B: bold
      }
  end

  def pretty(texts)
    return if texts.nil?
    texts.join(' ') # join any separated texts
    .gsub(/,\s*$/, '') # remove ending commas
    .gsub(/(^\s*|\s*$)/, '') # remove trailing whitespaces
    .gsub(/\s+/, ' ') # suppress multiple whitespaces
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
        @xref = elem
        store_xref elem.text

      when 'PAGE'
        if elem.has_text?
          elem.text.split(',').each do |t|
            next if /^\s*$/.match t
            store t
          end
        end

      when 'I'
        if elem.parent.name == 'PAGE' and elem.has_text?
          elem.text.split(',').each do |t|
            next if /^\s*$/.match t
            store t, true
          end
        end

      when 'B'
        if elem.parent.name == 'GROUP'
          @group = elem
        end
        if elem.parent.name == 'PAGE' and elem.has_text?
          elem.text.split(',').each do |t|
            next if /^\s*$/.match t
            store t, false, true
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

  def parse stringXml
    # text = File.read("index.xml")
    text = stringXml
    #text.gsub!(/(<I>|<\/I>|<B>|<\/B>)/, '') # remove formatting <I> elements, which cause so much problems
    text.gsub!(/(&ndash;)/, '-') # remove html escaped characters
    text.gsub!(/(&quot;)/, '"')
    xml = REXML::Document.new(text);

    xml.elements.each do |elem|
      parseElem elem
    end

    @index_items = @index_items.sort_by { |item| item[:page] }
  end

  def write_to()
    CSV.open("output_index.csv", "wb") do |csv|
      csv << ['Group', 'H0', 'H1', 'H2', 'Page', 'Latex Command', 'Raw XML Line (stripped of <I> and <B>)']
      @index_items.each do |item|
        csv << [item[:group], item[:H0], item[:H1], item[:H2], item[:page].to_s, item[:latex], "\"#{item[:raw]}\""]
      end
    end

    CSV.open("output_xref.csv", "wb") do |csv|
      csv << ['Group', 'H0', 'H1', 'H2', 'Page', 'Raw XML Line (stripped of <I> and <B>)']
      @index_xref.each do |xref|
        csv << [xref[:group], xref[:H0], xref[:H1], xref[:H2], xref[:xref], xref[:latex], "\"#{xref[:raw]}\""]
      end
    end
  end
end
