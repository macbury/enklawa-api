require "enklawa/api/version"
require "enklawa/api/response"
require "enklawa/api/program"
require "enklawa/api/category"
require "enklawa/api/episode"
require "enklawa/api/request"
require "enklawa/api/forum_thread"
require "open-uri"
require "nokogiri"
require "json"
require "cgi"
module Enklawa
  module Api

    def self.fetch
      request = Request.new
      request.get!
    end

  end
end
