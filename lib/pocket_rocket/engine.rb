 require "interpolate"

module PocketRocket
  class Engine

  #VALID_KEYS = [
  #  :code,
  #  :mass,
  #  :mass_decrease,
  #  :total_burn_time,
  #  :force_at_time,
  #  :sim_tick
  #]
  VALID_KEYS = [:code, :diameter, :length, :delay, :propellant_weight, :engine_weight, :thrust_curve, :manufacturer, :burn_time]

  attr_accessor(*VALID_KEYS)

  def initialize(options={})
    VALID_KEYS.each do |key|
      send("#{key}=", options[key])
    end
  end

  def force_value_at(time)
    if time >= burn_time
      return 0.0
    end
    value = @data.at(time)
    value
  end

  def mass_at_time(time)
    return engine_weight unless burn_time
    return (engine_weight - propellant_weight) if time >= burn_time
    return engine_weight - (time/burn_time)*propellant_weight
  end

  def thrust_curve=(data)
    @data = Interpolate::Points.new(data)
  end

  def burn_time
    @data.points.keys.last.to_f if @data
  end


  def propellant_weight
    @propellant_weight.to_f
  end

  def engine_weight
    @engine_weight.to_f
  end





end
end