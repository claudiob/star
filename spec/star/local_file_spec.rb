require 'spec_helper'
require 'star'
require 'open-uri'

describe Star::File do
  before { @original_content = "test this file" }

  context 'given a local file' do
    before do
      Star.configure do |config|
        config.remote = false
        config.location = File.expand_path('../../../tmp', __FILE__)
      end

      @file = Star::File.new name: 'test.txt', folder: 'locals'
      @file.open{|f| f.write @original_content}
    end

    describe '#path' do
      it 'returns the path to the local copy of the file' do
        expect(@file.path).to end_with '/tmp/locals/test.txt'
        expect(open(@file.path).read).to eq @original_content
      end
    end
  end
end
