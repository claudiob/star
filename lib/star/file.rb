require 'tempfile'
require 'net/http'
require 'openssl'
require 'base64'
require 'uri'

module Star
  class File
    attr_reader :content_type

    def initialize(options = {})
      @name = options.fetch :name, 'attachment'
      @content_type = options.fetch :content_type, 'application/octet-stream'
      @folder = options.fetch :folder, 'attachments'
    end

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

    def path
      [Star.configuration.location, @folder, @name].compact.join('/')
    end

    def store(tmp_file)
      if Star.remote?
        retry_on_error {store_remote tmp_file}
      else
        store_local(tmp_file)
      end
    end

    def delete
      Star.remote? ? delete_remote : delete_local
    end

    def copy_from(source)
      Star.remote? ? copy_from_remote(source) : copy_from_local(source)
    end

    def remote_path
      URI.escape path
    end

  private

    def retry_on_error
      yield
    rescue Net::HTTPFatalError => e
      raise if @retried
      sleep 5
      @retried = true
      retry
    end

    def store_remote(tmp_file)
      timestamp = Time.now.utc.strftime "%a, %d %b %Y %H:%M:%S UTC"
      signature = sign "PUT\n\n#{@content_type}\n#{timestamp}"
      ::File.open(tmp_file) do |body|
        request = put_file body, signature, timestamp
        response = Net::HTTP.start(host, 443, use_ssl: true) do |http|
          http.request request
        end
        response.error! unless response.is_a? Net::HTTPSuccess
      end
      sleep 3 # See https://forums.aws.amazon.com/message.jspa?messageID=370480
    end

    def store_local(tmp_file)
      FileUtils.mkdir_p ::File.dirname(path)
      FileUtils.mv tmp_file.path, path
    end

    def delete_remote
      timestamp = Time.now.utc.strftime "%a, %d %b %Y %H:%M:%S UTC"
      signature = sign "DELETE\n\n\n#{timestamp}"
      request = delete_file signature, timestamp
      response = Net::HTTP.start(host, 443, use_ssl: true) do |http|
        http.request request
      end
      response.error! unless response.is_a? Net::HTTPNoContent
    end

    def delete_file(signature, timestamp)
      Net::HTTP::Delete.new("/#{bucket}#{remote_path}").tap do |request|
        request.add_field 'Authorization', "AWS #{key}:#{signature}"
        request.add_field 'Date', timestamp
      end
    end

    def copy_from_remote(source)
      timestamp = Time.now.utc.strftime "%a, %d %b %Y %H:%M:%S UTC"
      extra = "x-amz-copy-source:/#{bucket}#{source.remote_path}"
      signature = sign "PUT\n\n#{@content_type}\n#{timestamp}\n#{extra}"
      request = copy_file signature, timestamp, source
      response = Net::HTTP.start(host, 443, use_ssl: true) do |http|
        http.request request
      end
      response.error! unless response.is_a? Net::HTTPSuccess
      sleep 3 # See https://forums.aws.amazon.com/message.jspa?messageID=370480
    end

    def copy_file(signature, timestamp, source)
      Net::HTTP::Put.new("/#{bucket}#{remote_path}").tap do |request|
        request.add_field 'Date', timestamp
        request.add_field 'Content-Type', @content_type
        request.add_field 'x-amz-copy-source', "/#{bucket}#{source.remote_path}"
        request.add_field 'Authorization', "AWS #{key}:#{signature}"
      end
    end

    def delete_local
      FileUtils.rm_f path
    end

    def copy_from_local(source)
      FileUtils.mkdir_p ::File.dirname(path)
      FileUtils.cp source.path, path
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
        request.add_field 'Content-Type', @content_type
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
