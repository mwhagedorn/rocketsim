require "interpolate"
require "formatador"

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
    VALID_KEYS = [:code, :diameter, :length, :delay, :propellant_weight, :engine_weight, :thrust_curve,:mass_curve, :manufacturer, :burn_time]

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
      return (engine_weight - propellant_weight) if time >= burn_time
      return @mdata.at(time)
    end

    def mass_curve=(data)
      data.merge({0.0 => engine_weight})
      @mdata = Interpolate::Points.new(data)
    end

    def thrust_curve=(data)
      @data = Interpolate::Points.new(data)
    end


    def propellant_weight
      @propellant_weight.to_f
    end

    def engine_weight
      @engine_weight.to_f
    end

    def inspect

       display = {}
      VALID_KEYS.each do |key|
        display[key] = self.send(key)
      end
      Formatador.display_table([display], VALID_KEYS)

    end

  end
end