module Star
  # Provides an object to store global configuration settings.
  #
  # This class is typically not used directly, but by calling
  # {Star::Config#configure Star.configure}, which creates and updates a single
  # instance of {Star::Configuration}.
  #
  # @example Set the API access key id/secret access key for AWS S3:
  #   Star.configure do |config|
  #     config.access_key_id = 'ABCDEFGHIJ1234567890'
  #     config.secret_access_key = 'ABCDEFGHIJ1234567890'
  #   end
  #
  # @see Star::Config for more examples.
  #
  # An alternative way to set global configuration settings is by storing
  # them in the following environment variables:
  #
  # * +AWS_ACCESS_KEY_ID+ to store the ACCESS KEY ID
  # * +AWS_SECRET_ACCESS_KEY+ to store the Client Secret for web/device apps
  # * +AWS_BUCKET+ to set the name of the S3 bucket
  # * +STAR_LOCATION+ to set the path for where to upload the file to
  # * +STAR_DURATION+ to set the time (in seconds) for the URL to exist for
  # * +STAR_REMOTE+ to store file in the local filesystem and not remotely
  # In case both methods are used together,
  # {Star::Config#configure Star.configure} takes precedence.
  #
  # @example Set the S3 access key id and secret access key:
  #   ENV['AWS_ACCESS_KEY_ID'] = 'ABCDEFGHIJ1234567890'
  #   ENV['AWS_SECRET_ACCESS_KEY'] = 'ABCDEFGHIJ1234567890'
  #
  class Configuration
    # @return [String] the S3 access key ID.
    attr_accessor :access_key_id

    # @return [String] the S3 secret access key.
    attr_accessor :secret_access_key

    # @return [String] the name of the S3 bucket.
    attr_accessor :bucket

    # @return [String] the path where remote files are uploaded to.
    attr_accessor :location

    # @return [Integer] the number of seconds during which the URL returned by
    #   calling #url on a remote file is publicly available.
    attr_accessor :duration

    # @return [Booelan] whether to store files remotely or locally.
    attr_accessor :remote

    # Initialize the global configuration settings, using the values of
    # the specified following environment variables by default.
    def initialize
      @access_key_id = ENV['AWS_ACCESS_KEY_ID']
      @secret_access_key = ENV['AWS_SECRET_ACCESS_KEY']
      @bucket = ENV['AWS_BUCKET']
      @location = ENV.fetch('STAR_LOCATION', '/')
      @duration = ENV.fetch('STAR_DURATION', '30').to_i
      @remote = %w(1 t T true TRUE).include? ENV.fetch('STAR_REMOTE', 't')
    end
  end
end
