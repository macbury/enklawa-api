module Enklawa
  module Api
    class Category < Struct.new(:id, :name)

      def to_h
        {
          id: id,
          name: name
        }
      end
    end
  end
end
