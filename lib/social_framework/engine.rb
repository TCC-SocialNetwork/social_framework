module SocialFramework
  class Engine < ::Rails::Engine
    isolate_namespace SocialFramework

    config.autoload_paths += %W(#{config.root}/lib/social_framework/graphs/)

    unless /[\w]+$/.match(Dir.pwd).to_s == "social_framework"
      initializer :append_migrations do |app|
        path = config.paths["db"].expanded.first

        FileUtils.rm_rf("#{path}/tmp")
        FileUtils.mkdir_p("#{path}/tmp/migrate")

        migrations_app = Dir.glob(app.config.paths["db/migrate"].first + "/*")
        migrations_framework = Dir.glob(config.paths["db/migrate"].first + "/*")

        migrations_framework.each do |m|
          migrate = m.to_s.scan(/([a-zA-Z_]+[^rb])/).last.first
          unless migrations_app.any? { |m_app| m_app.include?(migrate) }
            result = m.split("/").last
            FileUtils.cp(m, "#{path}/tmp/migrate/#{result}")
          end
        end
        
        app.config.paths["db/migrate"] << "#{path}/tmp/migrate"
      end
    end

    config.generators do |g|
      g.test_framework      :rspec,        :fixture => false
      g.fixture_replacement :factory_girl, :dir => 'spec/factories'
      g.assets false
      g.helper false
    end
  end
end
