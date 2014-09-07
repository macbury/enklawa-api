module Enklawa
  module Api
    class Episode < Struct.new(:id, :name, :description, :mp3, :pub_date, :link, :duration)

      def image
        "http://www.enklawa.net/images/episodes/#{id}.jpg"
      end

      def to_h
        {
          id: id,
          name: name,
          description: description,
          mp3: mp3,
          pub_date: pub_date,
          link: link,
          duration: duration,
          image: image
        }
      end

    end
  end
end
