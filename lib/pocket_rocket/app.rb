require "thor"
require "fog"
require "fog/hp"

Excon.defaults[:ssl_verify_peer] = false

module PocketRocket
  class App < Thor
    desc "list_rockets", "list rockets in the repo"
    def list_rockets
      @repo = Repository.new
      say @repo.rockets
    end

    desc "list_engines", "list rockets in the repo"
    def list_rockets
      @repo = Repository.new
      say @repo.codes
    end

  end
end

