require "feedjira"
require "sanitize"
require "yaml"
module Enklawa
  module Api
    class Request
      def initialize(url)
        @info_xml_url  = File.join([url, "info.xml"])
        @main_page_url = url
        @cache_key     = url.gsub(/[^a-z]/i,"") + ".yml"
        @cache = YAML::load_file(@cache_key) if File.exists?(@cache_key)
        @cache ||= {
          'images' => {},
          'durations' => {}
        }
      end

      def get!
        @response = Response.new
        get_info!
        get_programs!
        get_episodes!

        File.open(@cache_key, 'w') {|f| f.write @cache.to_yaml }

        @response
      end

      private

      def get_info!
        @info_xml_doc    = Nokogiri::XML(open(@info_xml_url).read)

        @response.skype = @info_xml_doc.search("settings call skype").text
        @response.phone = @info_xml_doc.search("settings call phone").text

        shoutcast_pls_url = CGI.unescape(@info_xml_doc.search("settings listen shoutcast").text)
        shoutcast_pls_url = "http:"+ shoutcast_pls_url unless shoutcast_pls_url.match("http")
        @response.radio   = open(shoutcast_pls_url).read.strip.split("\n")[-1].gsub("File1=","")
      end

      def get_programs!
        @info_xml_doc.search("programs p").each do |program_node|
          program              = Program.new
          program.base_url     = @main_page_url
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

      def check_if_image_exists_or_use_from_program(program, episode)
        return @cache['images'][episode.id] if @cache['images'].key?(episode.id)
        image = File.join([@main_page_url, "/images/episodes/#{episode.id}.jpg"])

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
          episode.duration    = get_duration(episode)
          episode.image       = check_if_image_exists_or_use_from_program(program, episode)
          program << episode  if episode.duration
        end
      end
    end
  end
end
