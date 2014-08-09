require "thor"
require_relative "repository"
require_relative "simulation"

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

    desc "run_simulation ROCKETNAME ENGINECODE", "run a simulation with rocket and engine"

    def run_simulation(rocket_name,engine_code)
     @sim = PocketRocket::Simulation.new()
     @sim.execute(rocket_name,engine_code)

    end


  end
end

