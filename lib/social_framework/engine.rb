require 'devise'

module SocialFramework
  class Engine < ::Rails::Engine
    isolate_namespace SocialFramework

    initializer :append_files do |app|
      config.paths["db/migrate"].expanded.each do |expanded_path|
        app.config.paths["db/migrate"] << expanded_path
      end
    end
  end
end
