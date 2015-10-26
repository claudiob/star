require 'spec_helper'
require 'star'
require 'open-uri'

describe Star::File do
  before { @original_content = "test this file" }

  context 'given a remote file' do
    before do
      Star.configuration.access_key_id      = ENV['STAR_TEST_AWS_ACCESS_KEY_ID']
      Star.configuration.secret_access_key  = ENV['STAR_TEST_SECRET_ACCESS_KEY']
      Star.configuration.bucket             = ENV['STAR_TEST_BUCKET']
      Star.configuration.location           = ENV['STAR_TEST_LOCATION']
      Star.configuration.duration           = 2
      Star.configuration.remote             = true

      @file = Star::File.new
      @file.open{|f| f.write @original_content}
    end

    describe '#url' do
      it 'returns the url to the remote file only for the specified duration' do
        @url = @file.url
        expect(open(@url).read).to eq @original_content
        sleep 3 # one extra second, just in case
        expect{open @url}.to raise_error OpenURI::HTTPError, '403 Forbidden'
      end
    end
  end
end
