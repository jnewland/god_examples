God.watch do |w|
  w.name            = "sinatra"
  w.interval        = 5.seconds
  w.start           = 'ruby ' + File.dirname(__FILE__) + '/scripts/sinatra.rb -p 8888'
  w.grace           = 10.seconds

  w.start_if do |start|
    start.condition(:process_running) do |c|
      c.running = false
    end
  end

  w.restart_if do |restart|
    restart.condition(:memory_usage) do |c|
      c.above = 15.megabytes
    end

    restart.condition(:http_response_code) do |c|
      c.host = 'localhost'
      c.port = '8888'
      c.path = '/heartbeat'
      c.code_is_not = %w(200 301 302)
    end
  end

end
