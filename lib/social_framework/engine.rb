require 'devise'

module SocialFramework
  class Engine < ::Rails::Engine
    isolate_namespace SocialFramework

    initializer_files("db/migrate")
    initializer_files("config/initializer")
  end

  def initializer_files(path)
    initializer :append_files do |app|
      unless app.root.to_s.match root.to_s
        config.paths[path].expanded.each do |expanded_path|
          app.config.paths[path] << expanded_path
        end
      end
    end
  end
end
