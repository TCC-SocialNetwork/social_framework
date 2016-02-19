module SocialFramework
  module Generators
    class DeviseRouteGenerator < Rails::Generators::Base

      source_root File.expand_path('../../templates/initializers/', __FILE__)

      desc "Add devise routes to app"

      def copy_devise_setup
        copy_file "devise.rb", "config/initializers/devise.rb"
      end

      def add_devise_routes
      	devise_route = "devise_for :users, class_name: 'SocialFramework::User'," <<
          "controllers: {sessions: 'users/sessions', registrations: 'users/registrations'}"
        
        route devise_route
      end
    end
  end
end