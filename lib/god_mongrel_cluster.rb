#GodMongrelCluster allows the use of configuration files generated with
#++mongrel_rails cluster::configure++ to be used with god. In a God config:
#
#    require 'god_mongrel_cluster'
#
#    Dir.glob('/etc/mongrel_cluster/*.conf').each do |mongrel_cluster|
#      cluster = GodMongrelCluster.new(mongrel_cluster)
#      cluster.watch
#    end
#
#FWIW: This is totally experimental and untested.

require 'yaml'
class GodMongrelCluster

  attr_accessor :options, :ports,
                :pid_file_ext, :pid_file_base, :pid_file_dir,
                :log_file_ext, :log_file_base, :log_file_dir

  def initialize(config_file)
    read_options(config_file)
  end

  def watch(watch_options = {})
    @ports.each do |port|
      God.watch do |w|
        w.group           = 'mongrel_cluster'
        w.name            = "mongrel_#{port}"
        w.uid             = @options['user'] if @options['user']
        w.gid             = @options['group'] if @options['group']
        w.start           = cmd(port)
        w.stop            = "mongrel_rails stop -P #{port_pid_file(port)}"
        w.restart         = "mongrel_rails restart -P #{port_pid_file(port)}"
        w.pid_file        = port_pid_file(port)
        w.interval        = watch_options[:interval] || 30.seconds
        w.grace           = watch_options[:grace] || 90.seconds

        w.behavior(:clean_pid_file)

        w.start_if do |start|
          start.condition(:process_running) do |c|
            c.running = false
            c.interval = watch_options[:process_running_interval] || w.interval
          end
        end

        w.restart_if do |restart|
          restart.condition(:memory_usage) do |c|
            c.above = watch_options[:memory_usage] || 200.megabytes
            c.times = watch_options[:memory_usage_times] || 1
            c.interval = watch_options[:memory_usage_interval] || w.interval
          end

          restart.condition(:cpu_usage) do |c|
            c.above = watch_options[:cpu_usage] || 50.percent
            c.times = watch_options[:cpu_usage_times] || 1
            c.interval = watch_options[:cpu_usage_interval] || w.interval
          end

          restart.condition(:http_response_code) do |c|
            c.code_is_not = watch_options[:http_response_code_is_not] || %w(200 304)
            c.host = watch_options[:http_response_code_host] || 'localhost'
            c.path = watch_options[:http_response_code_path] || '/'
            c.port = port
            c.timeout = watch_options[:http_response_code_timeout] || 30.seconds
            c.times = watch_options[:http_response_times] || 1
            c.interval = watch_options[:http_response_interval] || w.interval
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
  end


  def cmd(port)
    argv = [ "mongrel_rails" ]
    argv << "start"
    argv << "-d"
    argv << "-e #{@options['environment']}" if @options['environment']
    argv << "-a #{@options['address']}"  if @options['address']
    argv << "-c #{@options['cwd']}" if @options['cwd']
    argv << "-o #{@options['timeout']}" if @options['timeout']
    argv << "-t #{@options['throttle']}" if @options['throttle']
    argv << "-m #{@options['mime_map']}" if @options['mime_map']
    argv << "-r #{@options['docroot']}" if @options['docroot']
    argv << "-n #{@options['num_procs']}" if @options['num_procs']
    argv << "-B" if @options['debug']
    argv << "-S #{@options['config_script']}" if @options['config_script']
    argv << "--prefix #{@options['prefix']}" if @options['prefix']
    @cmd = argv.join " "
    @cmd += " -p #{port} -P #{port_pid_file(port)}"
    @cmd += " -l #{port_log_file(port)}"
  end

  def read_options(config_file)
    @options = {
      "environment" => ENV['RAILS_ENV'] || "development",
      "port" => 3000,
      "pid_file" => "tmp/pids/mongrel.pid",
      "log_file" => "log/mongrel.log",
      "servers" => 2
    }
    conf = YAML.load_file(config_file)
    @options.merge! conf if conf

    process_pid_file @options["pid_file"]
    process_log_file @options["log_file"]

    start_port = end_port = @only
    start_port ||=  @options["port"].to_i
    end_port ||=  start_port + @options["servers"] - 1
    @ports = (start_port..end_port).to_a
  end

  def process_pid_file(pid_file)
    @pid_file_ext = File.extname(pid_file)
    @pid_file_base = File.basename(pid_file, @pid_file_ext)
    @pid_file_dir = File.dirname(pid_file)
  end

  def process_log_file(log_file)
    @log_file_ext = File.extname(log_file)
    @log_file_base = File.basename(log_file, @log_file_ext)
    @log_file_dir = File.dirname(log_file)
  end

  def port_pid_file(port)
    pid_file = [@pid_file_base, port].join(".") + @pid_file_ext
    File.join(@pid_file_dir, pid_file)
  end

  def port_log_file(port)
    log_file = [@log_file_base, port].join(".") +  @log_file_ext
    File.join(@log_file_dir, log_file)
  end

end