require './lib/index_parser.rb'

p = Parser.new
p.parse 'index.xml'
p.write_to
