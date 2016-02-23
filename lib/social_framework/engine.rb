require 'devise'

module SocialFramework
  class Engine < ::Rails::Engine
    isolate_namespace SocialFramework

    initializer :append_files do |app|
      config.paths["db/migrate"].expanded.each do |expanded_path|
        app.config.paths["db/migrate"] << expanded_path
      end
    end

    config.generators do |g|
      g.test_framework      :rspec,        :fixture => false
      # g.fixture_replacement :factory_girl, :dir => 'spec/factories'
      g.assets false
      g.helper false
    end
  end
end
