require "feedjira"
require "sanitize"
require "yaml"
module Enklawa
  module Api
    class Request
      INFO_XML_URL       = "http://www.enklawa.net/info.xml"
      MAIN_PAGE_URL      = "http://enklawa.net"
      FORUM_FEED_URL     = "http://forum.enklawa.net/feed.php"
      ENKLAWA_CACHE_FILE = '/tmp/enklawa_cache.yml'
      def initialize
        @cache = YAML::load_file(ENKLAWA_CACHE_FILE) if File.exists?(ENKLAWA_CACHE_FILE)
        @cache ||= {
          'images' => {},
          'durations' => {}
        }
      end

      def get!
        @response = Response.new
        get_forum_feeds!
        get_categories!
        get_info!
        get_programs!
        get_episodes!

        File.open(ENKLAWA_CACHE_FILE, 'w') {|f| f.write @cache.to_yaml }

        @response
      end

      private

      def get_categories!
        doc = Nokogiri::HTML(open(MAIN_PAGE_URL))

        doc.search("select#ProgramsSelector option").each do |option|
          category      = Category.new
          category.name = option.text
          category.id   = option[:value].to_i

          @response.add_category(category)
        end
      end

      def get_info!
        @info_xml_doc    = Nokogiri::XML(open(INFO_XML_URL).read)

        @response.skype = @info_xml_doc.search("settings call skype").text
        @response.phone = @info_xml_doc.search("settings call phone").text

        shoutcast_pls_url = "http:"+CGI.unescape(@info_xml_doc.search("settings listen shoutcast").text)
        @response.radio   = open(shoutcast_pls_url).read.strip.split("\n")[-1].gsub("File1=","")
      end

      def get_programs!
        @info_xml_doc.search("programs p").each do |program_node|
          program              = Program.new
          program.id           = program_node[:id].to_i
          program.name         = program_node.search("name").text
          program.description  = program_node.search("description").text
          program.author       = program_node.search("author").text
          program.category_id  = program_node.search("cat").text.to_i
          program.live         = program_node.search("live").size > 0
          @response.programs << program
        end
      end

      def get_episodes!
        @response.programs.each do |program|
          feed = Feedjira::Feed.fetch_and_parse(program.feed_url)
          next if feed == 404
          feed.entries.each do |entry|
            build_episode_from_entry(entry, program)
          end
        end

        @response.programs.reject! { |program| program.episodes.empty? }
      end

      def get_forum_feeds!
        feed = Feedjira::Feed.fetch_and_parse(FORUM_FEED_URL)
        return if feed == 404

        feed.entries.each do |entry|
          thread             = ForumThread.new
          thread.id          = entry.id
          thread.title       = entry.title
          thread.link        = entry.url
          thread.content     = entry.content
          thread.pub_date    = entry.published
          thread.author      = entry.author
          @response.add_thread(thread)
        end
      end

      def check_if_image_exists_or_use_from_program(program, episode)
        return @cache['images'][episode.id] if @cache['images'].key?(episode.id)
        image = "http://www.enklawa.net/images/episodes/#{episode.id}.jpg"

        uri = URI(image)

        request  = Net::HTTP.new uri.host
        response = request.request_head uri.path
        unless response.code.to_i == 200
          image = program.image
        end

        @cache['images'][episode.id] = image

        return image
      end

      def get_duration(episode)
        return @cache['durations'][episode.id] if @cache['durations'].key?(episode.id)
        
        duration = nil
        temp_output_file_name = "/tmp/episode_metadata.txt"
        `ffmpeg2theora #{episode.mp3} > #{temp_output_file_name} 2>&1`
        if open(temp_output_file_name).read.match(/.+Duration:\s+(\d{2}):(\d{2}):(\d{2}).+/i)
          duration = ($3.to_i * 1000) + ($2.to_i * 60 * 1000) + ($1.to_i * 3600 * 1000)
          @cache['durations'][episode.id] = duration
        end

        return duration
      end

      def build_episode_from_entry(entry, program)
        episode             = Episode.new
        episode.id          = entry.id
        episode.name        = entry.title.split("-")[-1].strip
        episode.mp3         = entry.enclosure_url
        episode.link        = entry.url
        episode.description = Sanitize.clean(entry.summary).strip
        episode.pub_date    = entry.published

        if episode.mp3
          temp_output_file_name = "/tmp/episode_metadata_#{episode.id}.txt"
          `ffmpeg2theora #{episode.mp3} > #{temp_output_file_name} 2>&1` unless File.exists?(temp_output_file_name)
          if open(temp_output_file_name).read.match(/.+Duration:\s+(\d{2}):(\d{2}):(\d{2}).+/i)
            episode.duration    =
            episode.image       = check_if_image_exists_or_use_from_program(program, episode)
            program << episode
          end
        end
      end
    end
  end
end
