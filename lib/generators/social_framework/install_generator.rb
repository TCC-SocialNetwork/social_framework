module SocialFramework
  module Generators
    # Generator to add the principal files and configurations
    class InstallGenerator < Rails::Generators::Base

      source_root File.expand_path('../../templates/', __FILE__)

      desc "Init devise configurations with social_framework.rb, devise.rb, routes and principal views"

      # Copy social_framework.rb file to app, this file is used to define social_framework configurations
      def copy_social_framework_setup
        copy_file "initializers/social_framework.rb", "config/initializers/social_framework.rb"
      end
      
      # Copy devise.rb file to app, this file is used to define devise configurations
      def copy_devise_setup
        copy_file "initializers/devise.rb", "config/initializers/devise.rb"
      end

      # Copy translate file to app, this file is used to define devise configurations
      def copy_translate_file
        copy_file "../../../config/locales/devise.en.yml", "config/locales/devise.en.yml"
      end

      # Add devise routes to app maped to framework controllers
      def add_devise_routes
      	devise_route = "devise_for :users, class_name: 'SocialFramework::User',\n" <<
          "\t\tcontrollers: {sessions: 'users/sessions',\n"<<
          "\t\t\t\t\t\t\t\t\tregistrations: 'users/registrations',\n"<<
          "\t\t\t\t\t\t\t\t\tpasswords: 'users/passwords'}"
        
        route devise_route
      end

      # Add the principal devise views (registrations and sessions),
      # whith this it's possible register, update and authenticate users
      def add_views
        directory "views/registrations", "app/views/devise/registrations"
        directory "views/sessions", "app/views/devise/sessions"
        directory "views/shared", "app/views/devise/shared"
      end
    end
  end
end
