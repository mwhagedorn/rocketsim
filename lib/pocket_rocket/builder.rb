require "securerandom"
require 'json'
module PocketRocket
  class RocketBuilder

    attr_accessor :key, :template

    def initialize
      @key = SecureRandom.uuid
      @template = template_value
    end

    def key
      SecureRandom.uuid
    end

    private

    def template_value
      {
          type: "rocket",
          name: "aname",
          empty_weight_g: 00,
          max_body_tube_diameter_mm: 00,
          drag_coefficient: 0.85,
          notes: "my notes",
          parachute_diameter_cm: 00,
          parachute_shape: "hexagon"
      }
    end

  end
end