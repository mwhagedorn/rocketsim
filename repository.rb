require_relative "engine"
require_relative "rocket"
require_relative "wrasp_parser"


class Repository
  attr_accessor :motors
  attr_accessor :rockets

  def initialize
    @motors = {}
    @rockets = {}
    setup_engines
    setup_rockets



  end

  def setup_engines
    #@motors["A6"] = Engine.new(:mass            => 0.0164,
    #                          :mass_decrease   => 0.0004714,
    #                          :total_burn_time => 0.70,
    #                          :force_at_time   => [3.0, 9.0, 3.1, 2.5,2.5,0.5,0])
    #
    #@motors["A8"] = Engine.new(:mass            => 0.01635,
    #                          :mass_decrease   => 0.0004714,
    #                          :total_burn_time => 0.70,
    #                          :force_at_time   => [3.0,9.5,3.5,2.5,2.25,2.25,0.50,0])

    @motors["A8"] = Engine.new(WraspParser.new("./engines/Estes_A8.eng").parse.to_h)
    @motors["A3"] = Engine.new(WraspParser.new("./engines/Estes_A3.eng").parse.to_h)
    @motors["C6"] = Engine.new(WraspParser.new("./engines/Estes_C6.eng").parse.to_h)
    @motors["C5"] = Engine.new(WraspParser.new("./engines/Estes_C5.eng").parse.to_h)
    @motors["B6"] = Engine.new(WraspParser.new("./engines/Estes_B6.eng").parse.to_h)
    @motors["B4"] = Engine.new(WraspParser.new("./engines/Estes_B4.eng").parse.to_h)

    @motors.each_pair do |code, motor|
      motor.code = code
    end
  end

  def setup_rockets
    #dia in mm, weigth in grams
    @rockets["alpha"]  = Rocket.new( :name => "alpha",
                                     :empty_weight_g => 18.0,
                                     :max_body_tube_diameter_mm => 24.8,
                                     :drag_coefficient => 0.7)

    @rockets["alphaIII"] = Rocket.new(:name                      => "alphaIII",
                                      :empty_weight_g            => 29.0,
                                      :max_body_tube_diameter_mm => 24.8,
                                      :drag_coefficient          => 0.6)

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




end