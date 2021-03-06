require "thor"
require_relative "repository"
require_relative "simulation"
require_relative "builder"

module PocketRocket
  class App < Thor
    include Thor::Actions

    namespace("pr")

    desc "list_rockets", "list rockets in the repo"
    def list_rockets
      @repo = PocketRocket::Repository.new
      say @repo.rockets
    end

    desc "list_engines", "list engines in the repo"
    def list_engines
      @repo = PocketRocket::Repository.new
      say @repo.codes
    end

    desc "list_rocket_details ROCKETNAME", "list rocket details"
    def list_rocket_details(rocketID)
      @repo = PocketRocket::Repository.new
      say @repo.find_rocket_by_name(rocketID).inspect
    end

    desc "list_engine_details ENGINECODE", "list engine details"
    def list_engine_details(engineCode)
      @repo = PocketRocket::Repository.new
      say @repo.find_engine_by_code(engineCode).inspect
    end

    desc "run_simulation ROCKETNAME ENGINECODE LAUNCH_ANGLE", "run a simulation with rocket and engine and launch angle"
    method_options :mass => :numeric
    method_options :chute => :numeric
    def run_simulation(rocket_name,engine_code,launch_angle=90.0, wind_speed=0.0)
     @sim = PocketRocket::Simulation.new()
     chute = options[:chute]
     mass = options[:mass]
     if chute
       return  @sim.execute(rocket_name,engine_code,launch_angle, wind_speed,0.0,chute)
     end
     if mass
       return  @sim.execute(rocket_name,engine_code,launch_angle, wind_speed,mass)
     end
     @sim.execute(rocket_name,engine_code,launch_angle, wind_speed)

    end

    desc "create_template", "create a template for a rocket"

    def create_template
      @builder = PocketRocket::RocketBuilder.new
      say @builder.key
      say @builder.template.to_json
    end


  end
end
