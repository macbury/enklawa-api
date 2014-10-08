require "thor"
require "pry"
module Enklawa
  class Cli < Thor

    desc "console", "simple console playground"
    def console
      @response = Enklawa::Api.fetch
      binding.pry
    end

    desc "save", "fetch and save episodes"
    def save(url, path)
      @response = Enklawa::Api.fetch(url)
      @response.save(path)
    end

  end
end
