require 'spec_helper'

describe Enklawa::Api do
  describe "for fetching all info.xml and feed data" do
    let(:response) { @response ||= Enklawa::Api.fetch }

    it "should have basic information about response" do
      expect(response).not_to be_nil
      expect(response.class).to be(Enklawa::Api::Response)
      expect(response.skype).not_to be_nil
      expect(response.phone).not_to be_nil
      expect(response.radio).not_to be_nil
    end

    it "should have programs and episodes" do
      response.programs.each do |program|
        expect(program.id).not_to be_nil
        expect(program.image).not_to be_nil
        expect(program.name).not_to be_nil
        expect(program.description).not_to be_nil
        expect(program.author).not_to be_nil
        expect(program.live).not_to be_nil

        program.episodes.each do |episode|
          expect(episode.id).not_to be_nil
          expect(episode.name).not_to be_nil
          expect(episode.description).not_to be_nil
          expect(episode.image).not_to be_nil
          expect(episode.mp3).not_to be_nil
          expect(episode.pub_date).not_to be_nil
          expect(episode.link).not_to be_nil
        end
      end
    end
  end
end
