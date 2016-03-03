require "generator_spec"
require File.expand_path('../../../../lib/generators/social_framework/install_generator', __FILE__)

module SocialFramework
  module Generators
    RSpec.describe InstallGenerator, type: :generator do
      destination File.expand_path("../../tmp", __FILE__)

      before(:all) do
        prepare_destination

        FileUtils.mkdir_p("#{destination_root}/config") unless File.directory?("#{destination_root}/config")

        routes = File.new("#{destination_root}/config/routes.rb", "w+")
        routes.puts("SocialFramework::Engine.routes.draw do\nend")
        routes.close

        run_generator
      end

      after(:all) do
        FileUtils.rm_rf("spec/generators/tmp")
      end

      describe "SocialFramework install" do
        it "Verify social_framework.rb file" do
          expect(File).to exist("#{destination_root}/config/initializers/social_framework.rb")
        end
      end

      describe "Devise install" do
        it "Verify devise.rb file" do
          expect(File).to exist("#{destination_root}/config/initializers/devise.rb")
        end

        it "Verify translate file" do
          expect(File).to exist("#{destination_root}/config/locales/devise.en.yml")
        end

        it "Verify routes" do
          routes = File.read("#{destination_root}/config/routes.rb")
          expect(routes).to include("devise_for :users, class_name: 'SocialFramework::User'")
        end

        it "Verify views files" do
          expect(File).to exist("#{destination_root}/app/views/devise/registrations")
          expect(File).to exist("#{destination_root}/app/views/devise/sessions")
          expect(File).to exist("#{destination_root}/app/views/devise/shared")
        end
      end
    end
  end
end
