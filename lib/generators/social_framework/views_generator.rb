module SocialFramework
  module Generators
    # Generator to add devise views, that are: confirmations, passwords, registrations, sessions and unlocks
    # 
    # This generator add all views running 'rails generate social_framework:views'
    # 
    # Using the '-v' option can add specific views,
    # ====== Example:
    # To add registrations and sessions views execute 
    # 'rails generate social_framework:views -v registrations sessions'
    class ViewsGenerator < Rails::Generators::Base
      class_option :views, aliases: "-v", type: :array,
        desc: "Select specific view directories to generate (confirmations, passwords, registrations, sessions, unlocks, mailer)"

      source_root File.expand_path('../../templates/views/', __FILE__)
      
      desc "Add views to app"

      # Create devise directory in app/views and add devise views to app
      # 
      # Without '-v' option generate all views,
      # With '-v' option generate specific views.
      def add_views
        directory :shared, "app/views/devise/shared"

        if options[:views]
          options[:views].each do |directory|
            directory directory.to_sym, "app/views/devise/#{directory}"
          end
        else
          directory :confirmations, "app/views/devise/confirmations"
          directory :passwords, "app/views/devise/passwords"
          directory :registrations, "app/views/devise/registrations"
          directory :sessions, "app/views/devise/sessions"
          directory :unlocks, "app/views/devise/unlocks"
          directory :mailer, "app/views/devise/mailer"
        end
      end
    end
  end
end