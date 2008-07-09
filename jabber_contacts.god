$: << File.expand_path(File.dirname(__FILE__) + "/lib")
require 'passwords'
require 'jabber'

God::Contacts::Jabber.settings = { :jabber_id => 'bot@jnewland.com',
                                   :password  => PASSWORDS['bot@jnewland.com'] }

God.contact(:jabber) do |c|
  c.name      = 'jesse'
  c.jabber_id = 'jnewland@gmail.com'
end