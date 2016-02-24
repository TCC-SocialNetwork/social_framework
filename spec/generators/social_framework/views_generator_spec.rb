require "generator_spec"
require File.expand_path('../../../../lib/generators/social_framework/views_generator', __FILE__)

module SocialFramework
  module Generators
    RSpec.describe ViewsGenerator, type: :generator do
      destination File.expand_path("../../tmp", __FILE__)

      before(:each) do
        prepare_destination
      end

      after(:each) do
        FileUtils.rm_rf("spec/generators/tmp")
      end

      describe "Add views" do
        it "Add all" do
          run_generator
          expect(File).to exist("#{destination_root}/app/views/devise/confirmations")
          expect(File).to exist("#{destination_root}/app/views/devise/passwords")
          expect(File).to exist("#{destination_root}/app/views/devise/registrations")
          expect(File).to exist("#{destination_root}/app/views/devise/sessions")
          expect(File).to exist("#{destination_root}/app/views/devise/unlocks")
          expect(File).to exist("#{destination_root}/app/views/devise/mailer")
          expect(File).to exist("#{destination_root}/app/views/devise/shared")
        end

        it "Add specific views" do
          run_generator %w(-v confirmations registrations)
          expect(File).to exist("#{destination_root}/app/views/devise/confirmations")
          expect(File).to exist("#{destination_root}/app/views/devise/registrations")
          expect(File).to exist("#{destination_root}/app/views/devise/shared")

          expect(File).not_to exist("#{destination_root}/app/views/devise/sessions")
          expect(File).not_to exist("#{destination_root}/app/views/devise/unlocks")
          expect(File).not_to exist("#{destination_root}/app/views/devise/mailer")
          expect(File).not_to exist("#{destination_root}/app/views/devise/passwords")
        end
      end
    end
  end
end
