require 'devise'

module SocialFramework
  class Engine < ::Rails::Engine
    isolate_namespace SocialFramework

    initializer :append_files do |app|
      unless app.root.to_s.match root.to_s
        expanded_path("db/migrate", app)
        expanded_path("config/initializers", app)
      end
    end

    def expanded_path(path, app)
      config.paths[path].expanded.each do |expanded_path|
        app.config.paths[path] << expanded_path
      end
    end
  end
end
