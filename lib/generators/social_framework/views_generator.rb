module SocialFramework
  module Generators

    class ViewsGenerator < Rails::Generators::Base
      class_option :views, aliases: "-v", type: :array,
        desc: "Select specific view directories to generate (confirmations, passwords, registrations, sessions, unlocks, mailer)"

      source_root File.expand_path('../../templates/views/', __FILE__)
      
      desc "Add views to app"

      def add_views
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
        end
      end
    end
  end
end