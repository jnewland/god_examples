$: << File.expand_path(File.dirname(__FILE__) + "/../lib")
require 'god_test'

GodTest.new(:crashiness => 5)