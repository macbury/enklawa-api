module Enklawa
  module Api
    class Response
      attr_accessor :skype, :phone, :radio

      def initialize
        @programs   = []
        @categories = []
      end

      def programs
        @programs
      end

      def <<(program)
        @programs << program
      end

      def add_category(category)
        @categories << category
      end

      def to_h
        {
          version: VERSION,
          skype: skype,
          phone: phone,
          radio: radio,
          categories: @categories.map(&:to_h),
          programs: @programs.map(&:to_h)
        }
      end

      def save(filename)
        json = JSON.pretty_generate(to_h)
        File.open(filename, "w") { |f| f.write json }
      end
    end
  end
end
