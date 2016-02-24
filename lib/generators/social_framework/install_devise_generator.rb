module SocialFramework
  module Generators
    class InstallDeviseGenerator < Rails::Generators::Base

      source_root File.expand_path('../../templates/', __FILE__)

      desc "Init devise configurations with devise.rb, routes and principal views"

      def copy_devise_setup
        copy_file "initializers/devise.rb", "config/initializers/devise.rb"
      end

      def add_devise_routes
      	devise_route = "devise_for :users, class_name: 'SocialFramework::User',\n" <<
          "\t\tcontrollers: {sessions: 'users/sessions',\n"<<
          "\t\t\t\t\t\t\t\t\tregistrations: 'users/registrations',\n"<<
          "\t\t\t\t\t\t\t\t\tpasswords: 'users/passwords'}"
        
        route devise_route
      end

      def add_views
        directory "views/registrations", "app/views/devise/registrations"
        directory "views/sessions", "app/views/devise/sessions"
        directory "views/shared", "app/views/devise/shared"
      end
    end
  end
end