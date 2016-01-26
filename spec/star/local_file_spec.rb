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

    describe '#copy_from' do
      before { @target = Star::File.new name: 'tgt.txt', folder: 'locals/deep' }
      after  { @target.delete }
      it 'copies the existing local file to a different location' do
        expect(File.exists? @target.path).to be false
        @target.copy_from @file
        expect(File.exists? @target.path).to be true
        expect(open(@target.path).read).to eq @original_content
      end
    end
  end
end
