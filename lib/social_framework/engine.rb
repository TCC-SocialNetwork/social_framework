require 'devise'

module SocialFramework
  class Engine < ::Rails::Engine
    isolate_namespace SocialFramework

    initializer :append_migrations do |app|
      path = config.paths["db"].expanded.first

      FileUtils.rm_rf("#{path}/tmp")
      FileUtils.mkdir_p("#{path}/tmp/migrate")

      migrates_app = Dir.glob(app.config.paths["db/migrate"].first + "/*")
      migrates_framework = Dir.glob(config.paths["db/migrate"].first + "/*")

      migrates_framework.each do |m|
        migrate = m.to_s.scan(/([a-zA-Z_]+[^rb])/).last.first
        unless migrates_app.any? { |m_app| m_app.include?(migrate) }
          result = m.split("/").last
          FileUtils.cp(m, "#{path}/tmp/migrate/#{result}")
        end
      end
      
      app.config.paths["db/migrate"] << "#{path}/tmp/migrate"
    end

    config.generators do |g|
      g.test_framework      :rspec,        :fixture => false
      g.fixture_replacement :factory_girl, :dir => 'spec/factories'
      g.assets false
      g.helper false
    end
  end
end
