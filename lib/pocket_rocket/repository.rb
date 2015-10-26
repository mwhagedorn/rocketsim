require_relative "engine"
require_relative "models/rocket"
require_relative "wrasp_parser"
require 'couchbase'

class Hash
    include Hashie::Extensions::IndifferentAccess
end

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
      config = YAML::load_file(File.join(__dir__,'config', 'couchbase.yml'))["development"]
      Couchbase.connection_options = config.with_indifferent_access
      puts "*** #{config} ***"
      puts "*** #{Couchbase.bucket} ***"
    end

    def setup_engines
      @motors["A8"] = Engine.new(WraspParser.new("#{File.dirname(__FILE__)}/engines/Estes_A8.eng").parse.to_h)
      @motors["A3"] = Engine.new(WraspParser.new("#{File.dirname(__FILE__)}/engines/Estes_A3.eng").parse.to_h)
      @motors["C6"] = Engine.new(WraspParser.new("#{File.dirname(__FILE__)}/engines/Estes_C6.eng").parse.to_h)
      @motors["C5"] = Engine.new(WraspParser.new("#{File.dirname(__FILE__)}/engines/Estes_C5.eng").parse.to_h)
      @motors["B6"] = Engine.new(WraspParser.new("#{File.dirname(__FILE__)}/engines/Estes_B6.eng").parse.to_h)
      @motors["B4"] = Engine.new(WraspParser.new("#{File.dirname(__FILE__)}/engines/Estes_B4.eng").parse.to_h)

      @motors.each_pair do |code, motor|
        motor.code = code
      end
    end

    def setup_rockets
      #dia in mm, weigth in grams
      @rockets["alpha"] = Rocket.new(:name                      => "alpha",
                                     :empty_weight_g            => 18.0,
                                     :max_body_tube_diameter_mm => 24.8,
                                     :drag_coefficient          => 0.7)

      @rockets["astron"] = Rocket.new(:name                      => "astron",
                                      :empty_weight_g            => 43,
                                      :max_body_tube_diameter_mm => 23.0,
                                      :drag_coefficient          => 0.75)

      @rockets["alphaIII"] = Rocket.new(:name                      => "alphaIII",
                                        :empty_weight_g            => 29.0,
                                        :max_body_tube_diameter_mm => 24.8,
                                        :drag_coefficient          => 0.6)

      @rockets["mx774"] = Rocket.new(:name                      => "mx774",
                                     :empty_weight_g            => 84.0,
                                     :max_body_tube_diameter_mm => 46.0,
                                     :drag_coefficient          => 0.9)

      @rockets["dragonite"] = Rocket.new(:name                      => "dragonite",
                                         :empty_weight_g            => 51.0,
                                         :max_body_tube_diameter_mm => 28,
                                         :drag_coefficient          => 0.8)

      @rockets["astra"] = Rocket.new(:name                      => "astra",
                                     :empty_weight_g            => 23.0,
                                     :max_body_tube_diameter_mm => 25,
                                     :drag_coefficient          => 0.8)

      @rockets["red_max"] = Rocket.new(:name                      => "red_max",
                                       :empty_weight_g            => 68.0,
                                       :max_body_tube_diameter_mm => 42,
                                       :drag_coefficient          => 0.8)

      @rockets["payloader_one"] = Rocket.new(:name => "payloader_one",
                                             :empty_weight_g => 59.0,
                                             :max_body_tube_diameter_mm => 24.9,
                                             :drag_coefficient          => 0.75)

      @rockets["lr15"] = Rocket.new(:name => "lr15",
                                            :empty_weight_g => 38.0,
                                            :max_body_tube_diameter_mm => 24.8,
                                            :drag_coefficient          => 0.75)



    end

    def find_engine_by_code(code)
      @motors[code]
    end

    def find_rocket_by_name(code)
      @rockets[code]
    end

    def codes
      @motors.keys
    end

    def rockets
     Rocket.all
    end


  end

end
