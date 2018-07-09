require "timezone"
require "timezone_finder"

require_relative "oceans/timezone_coordinates"
require_relative "oceans/configuration"
require_relative "oceans/errors"

module Oceans
  class << self
    def configure
      self.configuration ||= Configuration.new
      yield(configuration)
    end

    def configuration
      @configuration ||= Configuration.new
    end

    def oceanize(lat, lng)
      timezone_coordinates[timezone_at(lat, lng)]

    rescue StandardError => e
      raise e unless configuration.silent_mode

      [lat, lng]
    end

    def timezone_at(lat, lng)
      timezone_name = timezone_finder.timezone_at(lat: lat, lng: lng)

      if configuration.use_proximity_algorithm
        timezone_name ||= timezone_finder.closest_timezone_at(lat: lat, lng: lng, delta_degree: configuration.delta_degree)
      end

      raise TimeZoneNotFoundError unless timezone_name

      timezone_name
    end

    def timezone_finder
      @timezone_finder ||= TimezoneFinder.create
    end
  end
end
