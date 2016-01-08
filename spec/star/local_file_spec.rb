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

    describe '#delete' do
      it 'deletes the existing local copy of the file' do
        expect(File.exists? @file.path).to be true
        @file.delete
        expect{@file.delete}.not_to raise_error
        expect(File.exists? @file.path).to be false
      end
    end
  end
end
