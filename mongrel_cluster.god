$: << File.expand_path(File.dirname(__FILE__) + "/lib")
require 'god_mongrel_cluster'

Dir.glob('/etc/mongrel_cluster/*.conf').each do |mongrel_cluster|
  cluster = GodMongrelCluster.new(mongrel_cluster)
  cluster.watch
end