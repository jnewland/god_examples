#A simple ruby class that loops and prints the current time. It will
#optionally leak memory or crash, depending on the keys passed into the
#++options++ hash; ++:delay++ controls how often the loop runs (defaults to 30
#seconds), ++:leakiness++ controls how much memory to leak per loop
#(if leakiness > 0, a new instance variable is created every loop that is 
#leakiness * the size of this file, and ++:crashiness++ determines how many
#times to loop (on average) before crashing.

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
