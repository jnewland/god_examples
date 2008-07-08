class GodTest

  def initialize(options = {})
    @crashiness = options[:crashiness] || nil
    @leakiness = options[:leakiness] || nil
    @delay = options[:delay] || 30
    run
  end

  def run
    loop do
      crash unless @crashiness.nil?
      leak unless @leakiness.nil?
      puts Time.now
      sleep(@delay)
    end
  end

  def crash
    raise "Crash!" if rand(@crashiness) == 1 || @crashiness == 1
  end
  
  def leak
    instance_variable_set("@leak#{rand(100000000)}".to_sym, (File.read(__FILE__)  * @leakiness))
  end

end
