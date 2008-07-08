require 'rubygems'
require 'daemons'

Daemons.run(File.dirname(__FILE__) + '/../scripts/crashy.rb', { :dir_mode => :normal, :dir => File.dirname(__FILE__) + '/../pids', :log_output => true })
