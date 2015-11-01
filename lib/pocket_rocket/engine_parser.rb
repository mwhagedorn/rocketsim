require_relative 'wrasp_parser'
require_relative 'rse_parser'

module PocketRocket
  class EngineParser

    VALID_KEYS = [:code, :diameter, :length, :delay, :propellant_weight, :engine_weight, :thrust_curve, :mass_curve, :manufacturer, :burn_time]

    attr_accessor(*VALID_KEYS)
    attr_accessor :filename

    def initialize(filename)
      @filename = filename
      @thrust_curve = Hash.new
      @mass_curve = Hash.new
      @parser = parser_factory
    end

    def parser_factory
      if File.extname(@filename) == ".eng"
        return WraspParser.new(self)
      end
      if File.extname(@filename) == ".rse"
        return RseParser.new(self)
      end
    end

    def parse
      @parser.parse
      self
    end


    def add_data_point(data_point)
      # data_point = [time, datum]
      @thrust_curve[data_point.first.to_f] = data_point.last.first.to_f
      @mass_curve[data_point.first.to_f] = data_point.last.last.to_f
    end

    def to_h
      {
          :code => self.code,
          :diameter => self.diameter,
          :length => self.length,
          :delay => self.delay,
          :propellant_weight => self.propellant_weight,
          :engine_weight => self.engine_weight,
          :thrust_curve => self.thrust_curve,
          :mass_curve => self.mass_curve,
          :manufacturer => self.manufacturer,
          :burn_time => self.burn_time

      }
    end
  end
end