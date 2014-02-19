require './lib/index_parser.rb'

p = Parser.new
p.parse File.read("index.xml")
p.write_to
