RAILS_ROOT = ENV['RAILS_ROOT'] ||= "/var/www/apps/test/current"
RUBY = `which ruby`.chomp
MONGREL_RAILS = `which mongrel_rails`.chomp
RAILS_ENV = ENV['RAILS_ENV'] ||= 'production'
MONGRELS = 2
MONGREL_START_PORT= 3000
USER = GROUP = 'deploy'

require 'god_web'
GodWeb.watch(:port => 3003)

0.upto(MONGRELS-1) do |n|
  port = MONGREL_START_PORT+n
  God.watch do |w|
    w.group           = 'mongrels'
    w.name            = "mongrel_#{port}"
    w.uid             = USER
    w.gid             = GROUP
    w.interval        = 30.seconds
    w.start           = "#{RUBY} #{MONGREL_RAILS} start --environment #{RAILS_ENV} --chdir #{RAILS_ROOT} --port #{port}"
    w.start_grace     = 90.seconds
    w.restart_grace   = 90.seconds
    w.log             = File.join(RAILS_ROOT, "log/mongrel_#{port}.log")

    w.start_if do |start|
      start.condition(:process_running) do |c|
        c.interval = 5.seconds
        c.running = false
      end
    end

    w.restart_if do |restart|
      restart.condition(:memory_usage) do |c|
        c.above = 50.megabytes
      end

      restart.condition(:cpu_usage) do |c|
        c.above = 50.percent
        c.times = 2
      end

      restart.condition(:http_response_code) do |c|
        c.code_is_not = 200
        c.host = 'localhost'
        c.path = '/pulse/pulse'
        c.port = port
        c.timeout = 30.seconds
        c.times = [2, 3]
      end
    end

    w.lifecycle do |on|
      on.condition(:flapping) do |c|
        c.to_state = [:start, :restart]
        c.times = 5
        c.within = 5.minute
        c.transition = :unmonitored
        c.retry_in = 10.minutes
        c.retry_times = 5
        c.retry_within = 2.hours
      end
    end
  end
end