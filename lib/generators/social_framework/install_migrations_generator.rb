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
            file = "social_framework_#{migrate.pluralize}.rb"
            file = migrations.select { |m| m.include?(file) }.first
            unless file.nil? or file.empty?
              file_name = file.split("/").last
              copy_file file, "db/migrate/#{file_name}"
            else
              puts "Could not find migration: '#{migrate}'"
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
