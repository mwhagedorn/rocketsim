class WraspParser

  VALID_KEYS = [:code, :diameter, :length, :delay, :propellant_weight, :engine_weight, :thrust_curve, :manufacturer]

  attr_accessor(*VALID_KEYS)

  def initialize(filename)
    @filename = filename
    @thrust_curve = []
  end

  def parse
    File.open(@filename, "r").each_line do |line|
      case line
        when /^;/

        when /(?<code>^[A-J]\d)\s(?<dia>\d{2,})\s(?<len>\d{2,})\s(?<delay>.*)\s(?<prop_m>\d+\.\d+)\s(?<mass>\d+\.\d+)\s(?<brand>\w+)/
          self.code = Regexp.last_match(:code)
          self.diameter = Regexp.last_match(:dia)
          self.length = Regexp.last_match(:len)
          self.delay = Regexp.last_match(:delay)
          self.propellant_weight = Regexp.last_match(:prop_m)
          self.engine_weight = Regexp.last_match(:mass)
          self.manufacturer = Regexp.last_match(:brand)
        when /(?<time>\d+\.\d+)\s(?<thrust>\d+\.\d+)/
          thrust_curve_data([Regexp.last_match(:time), Regexp.last_match(:thrust)])
      end
    end
    @thrust_curve = Hash[*@thrust_curve.flatten.collect { |i| i.to_f }]

    self
  end

  #A8 18 70 3-5 0.0033 0.01635 Estes
  #(^[A-J]\d)\s(\d{2,})\s(\d{2,})\s(\d+-\d+)\s(\d+\.\d+)\s(\d+\.\d+)\s(\w+)
  #capture 1 = code, 2 = dia, 3 = len, 4 = delay, 5 = prop_weight, 6 = weight, 7 = brand
  def comment(commentline)
    puts commentline
  end



  def thrust_curve_data(data_point)
    @thrust_curve << data_point
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
      :manufacturer => self.manufacturer

    }
  end









end
