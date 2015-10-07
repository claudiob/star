require 'spec_helper'
require 'star/remote_file'
require 'open-uri'

describe Star::RemoteFile do
  context 'given a remote file with original content' do
    before do
      @original_content = "test this file"
      @remote_file = Star::RemoteFile.new
      @remote_file.open{|f| f.write @original_content}
    end

    describe '#url' do
      it 'returns the location of the remote file' do
        expect(open(@remote_file.url).read).to eq @original_content
      end

      xit 'expires after 30 seconds' do
        expect(open @remote_file.url).to be_a_url
        sleep 30
        expect(open @remote_file.url).to raise_error
      end
    end
  end
end
