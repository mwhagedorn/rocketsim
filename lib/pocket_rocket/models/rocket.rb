require_relative 'named'

class Rocket < Couchbase::Model

  attribute :name
  attribute :empty_weight_g
  attribute :max_body_tube_diameter_mm
  attribute :drag_coefficient
  attribute :current_mass
  attribute :engine
  attribute :parachute_shape
  attribute :parachute_diameter_cm

  attr_accessor :mass_override



  view :all, :stale => false, :include_docs => true


  def mass
    empty_weight_g*0.001
  end

  def effective_mass(time)
    if @mass_override > 0.0
      puts("*** mass override ***")
      return @mass_override*0.001 + engine.mass_at_time(time)
    end
    mass + engine.mass_at_time(time)
  end

  def inspect

    display = {}
    self.attributes.each do |key,value|
     display[key] = value
    end

    Formatador.display_table([display], self.attributes.keys)

  end



  private

  def radius
    :max_body_tube_diameter / 2
  end
end

