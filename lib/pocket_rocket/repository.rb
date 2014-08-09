require_relative "engine"
require_relative "rocket"
require_relative "wrasp_parser"

module PocketRocket
class Repository
  attr_accessor :motors
  attr_accessor :rockets

  def initialize
    @motors  = {}
    @rockets = {}
    setup_engines
    setup_rockets


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
                                   :drag_coefficient          => 1.5)

  end

  def find_engine_by_code(code)
    @motors[code]
  end

  def find_rocket_by_name(code)
    @rockets[code]
  end

  def self.codes
    @motors.keys
  end

  def self.rockets
    @rockets.keys
  end


end

end

