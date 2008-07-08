module God
  module Behaviors
    class Speak < Behavior

      def before_start
        `say "Starting now"`

        'announced start'
      end

      def before_stop
        `say "Stopping now"`

        'announced stop'
      end

    end
  end
end

God.watch do |w|
  w.name            = "leaky"
  w.interval        = 5.second
  w.start           = 'ruby ' + File.dirname(__FILE__) + '/scripts/leaky.rb'

  w.behavior(:speak)

  w.start_if do |start|
    start.condition(:process_running) do |c|
      c.running = false
    end
  end

  w.restart_if do |restart|
    restart.condition(:memory_usage) do |c|
      c.above = 2.megabytes
    end
  end

end
