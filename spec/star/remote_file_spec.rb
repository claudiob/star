require 'spec_helper'
require 'star'
require 'open-uri'

describe Star::File do
  before { @original_content = "test this file" }
  before do
    Star.configuration.access_key_id      = ENV['STAR_TEST_AWS_ACCESS_KEY_ID']
    Star.configuration.secret_access_key  = ENV['STAR_TEST_SECRET_ACCESS_KEY']
    Star.configuration.bucket             = ENV['STAR_TEST_BUCKET']
    Star.configuration.location           = ENV['STAR_TEST_LOCATION']
    Star.configuration.duration           = 2
    Star.configuration.remote             = true
  end

  context 'given a remote file' do
    before do
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
        expect{open @url}.to raise_error OpenURI::HTTPError
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

  context 'given a new file' do
    subject(:file) { Star::File.new }
    subject(:store) { file.open{|f| f << "some text to store in a remote file"} }

    context 'given AWS is temporarily unavailable' do
      let(:http_error) { Net::HTTPFatalError.new(nil, nil) }
      before { expect(Net::HTTP).to receive(:start).once.and_raise http_error }

      context 'every time' do
        before { expect(Net::HTTP).to receive(:start).at_least(:once).and_raise http_error }

        it 'raises Net::HTTPFatalError' do
          expect{ store }.to raise_error Net::HTTPFatalError
        end
      end

      context 'only once' do
        before { expect(Net::HTTP).to receive(:start).at_least(:once).and_return retry_response }
        let(:retry_response) { Net::HTTPOK.new nil, nil, nil }

        it 'works' do
          expect{ store }.not_to raise_error
        end
      end
    end
  end
end
