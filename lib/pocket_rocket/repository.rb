require_relative "engine"
require_relative "models/rocket"
require_relative "engine_parser"
require 'couchbase'
require 'active_support/core_ext/hash'

module PocketRocket
  class Repository
    BUCKET_NAME = "pocket_rocket"
    attr_accessor :motors
    attr_accessor :rockets

    def initialize
      @motors  = {}
      @rockets = {}
      setup_engines
      setup_rockets
      config = HashWithIndifferentAccess.new(YAML::load_file(File.join(__dir__,'config', 'couchbase.yml'))["development"])
      Couchbase.connection_options = config.with_indifferent_access
    end

    def setup_engines
      @motors["A8"] = Engine.new(EngineParser.new("#{File.dirname(__FILE__)}/engines/Estes_A8.rse").parse.to_h)
      @motors["A6"] = Engine.new(EngineParser.new("#{File.dirname(__FILE__)}/engines/Quest_A6.rse").parse.to_h)
      #@motors["A3"] = Engine.new(EngineParser.new("#{File.dirname(__FILE__)}/engines/Estes_A3.eng").parse.to_h)
      @motors["A10"] = Engine.new(EngineParser.new("#{File.dirname(__FILE__)}/engines/Estes_A10.eng").parse.to_h)
      @motors["C6"] = Engine.new(EngineParser.new("#{File.dirname(__FILE__)}/engines/Estes_C6.rse").parse.to_h)
      #@motors["C5"] = Engine.new(EngineParser.new("#{File.dirname(__FILE__)}/engines/Estes_C5.eng").parse.to_h)
      @motors["B6"] = Engine.new(EngineParser.new("#{File.dirname(__FILE__)}/engines/Estes_B6.rse").parse.to_h)
      @motors["B4"] = Engine.new(EngineParser.new("#{File.dirname(__FILE__)}/engines/Estes_B4.rse").parse.to_h)

      @motors.each_pair do |code, motor|
        motor.code = code
      end
    end

    def setup_rockets
      #switched to couchbase

    end

    def find_engine_by_code(code)
      @motors[code]
    end

    def find_rocket_by_name(name)
      Rocket.all.to_a.select { |item| item.name == name }.first
    end

    def codes
      @motors.keys
    end

    def rockets
     Rocket.all.to_a.collect { |item| item.name }
    end


  end

end
