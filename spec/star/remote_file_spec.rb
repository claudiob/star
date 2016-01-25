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

    describe '#delete' do
      it 'deletes the remote copy of the file' do
        @url = @file.url
        expect{open @url}.not_to raise_error
        @file.delete
        expect{open @url}.to raise_error OpenURI::HTTPError, '404 Not Found'
        expect{@file.delete}.not_to raise_error
      end
    end

    describe '#copy_from' do
      before { @target = Star::File.new folder: 'attachments/deep' }
      after  { @target.delete }
      it 'copies the existing remote file to a different location' do
        expect{open @target.url}.to raise_error OpenURI::HTTPError, '404 Not Found'
        @target.copy_from @file
        expect{open @target.url}.not_to raise_error
        expect(open(@target.url).read).to eq @original_content
      end
    end
  end
end
