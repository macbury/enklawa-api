module Enklawa
  module Api
    class Program < Struct.new(:id, :name, :description, :author, :live)
      attr_accessor :episodes

      def initialize
        self.episodes = []
      end

      def image
        "http://www.enklawa.net/images/programs/#{id}.jpg"
      end

      def <<(episode)
        self.episodes << episode
      end

      def feed_url
        "http://www.enklawa.net/program#{self.id}.xml"
      end

      def to_h
        {
          id: id,
          name: name,
          description: description,
          author: author,
          live: live,
          image: image,
          feed_url: feed_url,
          episodes: episodes.map(&:to_h)
        }
      end
    end
  end
end
