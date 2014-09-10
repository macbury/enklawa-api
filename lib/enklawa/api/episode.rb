require "uri"
require "net/http"
require "time"
module Enklawa
  module Api
    class Episode < Struct.new(:id, :name, :description, :mp3, :pub_date, :link, :duration, :image)

      def check_if_image_exists_or_use_from_program(program)
        self.image = "http://www.enklawa.net/images/episodes/#{id}.jpg"

        uri = URI(image)

        request  = Net::HTTP.new uri.host
        response = request.request_head uri.path
        unless response.code.to_i == 200
          self.image = program.image
        end
      end

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
