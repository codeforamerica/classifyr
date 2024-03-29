# frozen_string_literal: true

# Helper methods for working with the application configuration.
module AppConfig
  extend ActiveSupport::Concern

  class_methods do
    def app_config
      Rails.application.config
    end

    def config
      app_config.classifyr[name.underscore] ||= {}
    end
  end
end
