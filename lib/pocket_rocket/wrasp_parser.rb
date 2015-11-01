module PocketRocket
  class WraspParser

    attr_accessor :context

    def initialize(context)
      @context = context
    end

    def parse
      File.open(context.filename, "r").each_line do |line|
        case line
          when /^;/

          when /(?<code>^[A-J]\d)\s(?<dia>\d{2,})\s(?<len>\d{2,})\s(?<delay>.*)\s(?<prop_m>\d+\.\d+)\s(?<mass>\d+\.\d+)\s(?<brand>\w+)/
            context.code = Regexp.last_match(:code)
            context.diameter = Regexp.last_match(:dia)
            context.length = Regexp.last_match(:len)
            context.delay = Regexp.last_match(:delay)
            context.propellant_weight = Regexp.last_match(:prop_m)
            context.engine_weight = Regexp.last_match(:mass)
            context.manufacturer = Regexp.last_match(:brand)
          when /(?<time>\d+\.\d+)\s(?<thrust>\d+\.\d+)/
            context.add_data_point([Regexp.last_match(:time), [Regexp.last_match(:thrust), context.engine_weight]])
        end
      end
      context.add_data_point([0.0, [0.0, context.engine_weight]])
      context.burn_time = context.thrust_curve.keys.sort.last
      context.mass_curve.each do |key,value|
        #update the mass curve once you know the total burn time
        context.mass_curve[key.to_f] = (context.engine_weight.to_f - (key.to_f/context.burn_time.to_f)*context.propellant_weight.to_f)
      end


    end
  end
end
