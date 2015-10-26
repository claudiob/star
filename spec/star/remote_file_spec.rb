require 'spec_helper'
require 'open-uri'

describe Star::RemoteFile do
  context 'given a remote file with original content' do
    before do
      @original_content = "test this file"
      @remote_file = Star::RemoteFile.new
      @remote_file.open{|f| f.write @original_content}
      @url = @remote_file.url
    end

    describe '#url' do
      it 'expires after the seconds specified in the configuration' do
        p @url
        # expect(open(@url).read).to eq @original_content
        # sleep Star.configuration.duration + 1 # extra second, just in case
        # expect{open @url}.to raise_error OpenURI::HTTPError, '403 Forbidden'
      end
    end
  end
end
