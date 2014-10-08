module Enklawa
  module Api
    class Program < Struct.new(:id, :name, :description, :author, :live, :category_id)
      attr_accessor :episodes, :base_url

      def initialize
        self.episodes = []
      end

      def image
        if base_url.match("enklawa")
          File.join([base_url, "/images/programs/#{id}.jpg"])
        else
          File.join([base_url, "/images/programs/240/#{id}.jpg"])
        end
      end

      def <<(episode)
        self.episodes << episode
      end

      def feed_url
        File.join([base_url, "/program#{self.id}.xml"])
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
          category_id: category_id,
          episodes: episodes.map(&:to_h)
        }
      end
    end
  end
end
