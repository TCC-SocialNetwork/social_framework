module SocialFramework
  module Generators
    class DeviseRouteGenerator < Rails::Generators::Base

      desc "Add devise routes to app"

      def add_devise_routes
      	devise_route = "devise_for :users, class_name: 'SocialFramework::User'," <<
    	"controllers: {sessions: 'users/sessions', registrations: 'users/registrations'}"
        route devise_route
      end
    end
  end
end