require 'tempfile'
require 'net/http'
require 'openssl'
require 'base64'
require 'uri'
require 'star/config'

module Star
  class RemoteFile

    def open
      Tempfile.open 'tmp_file' do |tmp_file|
        yield tmp_file
        tmp_file.flush
        store tmp_file
      end
    end

    def url
      "https://#{host}/#{bucket}#{remote_path}?#{url_params}"
    end

    def store(tmp_file)
      timestamp = Time.now.utc.strftime "%a, %d %b %Y %H:%M:%S UTC"
      signature = sign "PUT\n\n#{content_type}\n#{timestamp}"
      File.open(tmp_file) do |body|
        request = put_file body, signature, timestamp
        response = Net::HTTP.start(host, 443, use_ssl: true) do |http|
          http.request request
        end
        response.error! unless response.is_a? Net::HTTPSuccess
      end
      sleep 3 # See https://forums.aws.amazon.com/message.jspa?messageID=370480
    end

  private

    def content_type
      'text/plain'
    end

    def url_params
      expires_at = Time.now.to_i + Star.configuration.duration
      digest = OpenSSL::Digest.new 'sha1'
      params = "response-content-disposition=attachment"
      string = "GET\n\n\n#{expires_at}\n/#{bucket}#{remote_path}?#{params}"
      hmac = OpenSSL::HMAC.digest digest, secret, string
      code = escape Base64.encode64(hmac)

      "#{params}&AWSAccessKeyId=#{key}&Expires=#{expires_at}&Signature=#{code}"
    end

    def put_file(body, signature, timestamp)
      Net::HTTP::Put.new("/#{bucket}#{remote_path}").tap do |request|
        request.body_stream = body
        request.initialize_http_header 'Content-Length' => body.size.to_s
        request.add_field 'Host', host
        request.add_field 'Date', timestamp
        request.add_field 'Content-Type', content_type
        request.add_field 'Authorization', "AWS #{key}:#{signature}"
      end
    end

    def sign(action)
      digest = OpenSSL::Digest.new 'sha1'
      string = "#{action}\n/#{bucket}#{remote_path}"
      Base64.strict_encode64 OpenSSL::HMAC.digest(digest, secret, string)
    end

    def escape(string)
      s = {'+' => "%2B", '=' => "%3D", '?' => '%3F', '@' => '%40', '$' => '%24',
           '&' => '%26', ',' => '%2C', '/' => '%2F', ':' => '%3A', ';' => '%3B'}
      URI.escape(string.strip).gsub(/./) {|c| s.fetch(c, c)}
    end

    def host
      "s3.amazonaws.com"
    end

    def remote_path
      URI.escape "/#{Star.configuration.location}/foobar.txt"
    end

    def key
      Star.configuration.access_key_id
    end

    def secret
      Star.configuration.secret_access_key
    end

    def bucket
      Star.configuration.bucket
    end
  end
end
