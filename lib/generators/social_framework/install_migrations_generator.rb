module SocialFramework
  module Generators
    # Generator to add migrations in the application
    class InstallMigrationsGenerator < Rails::Generators::Base
      class_option :migrations, aliases: "-m", type: :array,
        desc: "Select specific migrations to generate (edge, edge_relationship, user, relationship)"

      source_root File.expand_path('../../../db/migrate', __FILE__)

      desc "Install migrations to application"

      # Copy the migrations to application
      # 
      # Without '-m' option copy all migrations,
      # With '-m' option copy specifics migrations.
      def add_migrations
      	migrations = Dir.glob(SocialFramework::Engine.config.paths["db/migrate"].first + "/*")

        if options[:migrations]
          options[:migrations].each do |migrate|
            migrate = "social_framework_#{migrate.pluralize}.rb"
            migrate = migrations.select { |m| m.include?(migrate) }.first
            unless migrate.nil? and migrate.empty?
              file = migrate.split("/").last
              copy_file migrate, "db/migrate/#{file}"
            end
          end
        else
          migrations.each do |migrate|
            file = migrate.split("/").last 
            copy_file migrate, "db/migrate/#{file}"
          end
        end
      end
    end
  end
end
