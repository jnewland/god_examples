$: << File.expand_path(File.dirname(__FILE__) + "/lib")
require 'passwords'

God.watch do |w|
  w.name            = "jabber_bot"
  w.interval        = 5.seconds
  w.start           = 'ruby ' + File.dirname(__FILE__) + '/scripts/jabber_bot.rb'
  w.grace           = 15.seconds

  w.start_if do |start|
    start.condition(:process_running) do |c|
      c.running = false
    end
  end

  w.restart_if do |restart|
    restart.condition(:memory_usage) do |c|
      c.above = 20.megabytes
    end

    restart.condition(:lambda) do |c|
      c.interval = 15.seconds
      c.lambda = lambda do
        require 'xmpp4r-simple'
        im = Jabber::Simple.new('god@jnewland.com', PASSWORDS['god@jnewland.com'])
        im.deliver('bot@jnewland.com', 'ping')
        sleep(5)
        return true unless im.received_messages?
        chat = im.received_messages.find { |msg| msg.type == :chat}
        return true unless chat.body =~ /pong/
      end
    end
  end

end