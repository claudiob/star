require 'star/configuration'

module Star
  # Provides methods to read and write global configuration settings.
  #
  # @example Set the API key for a server-only YouTube app:
  #   Star.configure do |config|
  #     config.access_key_id = 'ABCDEFGHIJ1234567890'
  #   end
  #
  # Note that Star.configure has precedence over values through with
  # environment variables (see {Star::Configuration}).
  #
  module Config
    # Yields the global configuration to the given block.
    #
    # @example
    #   Star.configure do |config|
    #     config.access_key_id = 'ABCDEFGHIJ1234567890'
    #   end
    #
    # @yield [Star::Configuration] The global configuration.
    def configure
      yield configuration if block_given?
    end

    # @return [Boolean] whether files are stored remotely (on S3).
    def remote?
      !!configuration.remote
    end

    # Returns the global {Star::Models::Configuration} object.
    #
    # While this method _can_ be used to read and write configuration settings,
    # it is easier to use {Star::Config#configure} Star.configure}.
    #
    # @example
    #     Star.configuration.access_key_id = 'ABCDEFGHIJ1234567890'
    #
    # @return [Star::Configuration] The global configuration.
    def configuration
      @configuration ||= Star::Configuration.new
    end
  end

  # @note Config is the only module auto-loaded in the Star module,
  #       in order to have a syntax as easy as Star.configure

  extend Config
end
