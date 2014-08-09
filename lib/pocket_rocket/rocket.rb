module PocketRocket
  class Rocket
  VALID_KEYS = [
    :empty_weight_g,
    :max_body_tube_diameter_mm,
    :drag_coefficient,
    :engine,
    :current_mass
  ]

  attr_accessor(*VALID_KEYS)

  def initialize(options={})
    VALID_KEYS.each do |key|
      send("#{key}=", options[key])
    end
  end

  def mass
    empty_weight_g*0.001
  end

  def effective_mass(time)
    mass + engine.mass_at_time(time)
  end

  def inspect

    display = {}
    VALID_KEYS.each do |key|
      display[key] = self.send(key)
    end
    Formatador.display_table([display], VALID_KEYS)

  end

  private

    def radius
      :max_body_tube_diameter / 2
    end
end
end