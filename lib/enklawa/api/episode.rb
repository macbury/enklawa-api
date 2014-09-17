require "uri"
require "net/http"
require "time"
module Enklawa
  module Api
    class Episode < Struct.new(:id, :name, :description, :mp3, :pub_date, :link, :duration, :image)

      def to_h
        {
          id: id.to_i,
          name: name,
          description: description,
          mp3: mp3,
          pub_date: pub_date.utc.iso8601,
          link: link,
          duration: duration,
          image: image
        }
      end

    end
  end
end
