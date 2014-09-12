module Enklawa
  module Api
    class ForumThread < Struct.new(:id, :title, :content, :pub_date, :link)

      def to_h
        {
          id: id,
          title: title,
          content: content,
          pub_date: pub_date.utc.iso8601,
          link: link
        }
      end

    end
  end
end
