#The simplest possible watch
God.watch do |w|
  w.name            = "stable"
  w.interval        = 30.seconds
  w.start           = 'ruby ' + File.dirname(__FILE__) + '/scripts/stable.rb'

  w.start_if do |start|
    start.condition(:process_running) do |c|
      c.running = false
    end
  end

end
