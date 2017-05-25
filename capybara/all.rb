require "./cud_point.rb"
require "./read_point.rb"
require "./cud_line.rb"
require "./read_line.rb"
require "./cud_polygon.rb"
require "./read_polygon.rb"

CudPointTests.new('http://localhost:3000/', 'rails', 1).run_tests
ReadPointTests.new('http://localhost:3000/', 'rails', 1).run_tests
CudLineTests.new('http://localhost:3000/', 'rails', 1).run_tests
ReadLineTests.new('http://localhost:3000/', 'rails', 1).run_tests
CudPolygonTests.new('http://localhost:3000/', 'rails', 1).run_tests
ReadPolygonTests.new('http://localhost:3000/', 'rails', 1).run_tests