module SocialFramework
  module Generators
    class DeviseRouteGenerator < Rails::Generators::Base

      desc "Add devise routes to app"

      def add_devise_routes
        route "devise_for :users, class_name: 'SocialFramework::User'"
      end
    end
  end
end