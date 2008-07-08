$: << File.expand_path(File.dirname(__FILE__) + "/../lib")
require 'god_test'

GodTest.new(:leakiness => 100, :delay => 1)
