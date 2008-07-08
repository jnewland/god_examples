require 'rubygems'
require 'daemons'

Daemons.run(File.dirname(__FILE__) + '/../scripts/stable.rb', { :dir_mode => :normal, :dir => File.dirname(__FILE__) + '/../pids', :log_output => true })
