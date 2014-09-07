module Enklawa
  module Api
    class Response
      attr_accessor :skype, :phone, :radio

      def initialize
        @programs = []
      end

      def programs
        @programs
      end

      def <<(program)
        @programs << program
      end

      def to_h
        {
          skype: skype,
          phone: phone,
          radio: radio,
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
