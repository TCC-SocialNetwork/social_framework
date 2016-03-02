require "generator_spec"
require File.expand_path('../../../../lib/generators/social_framework/install_migrations_generator', __FILE__)

module SocialFramework
  module Generators
    RSpec.describe InstallMigrationsGenerator, type: :generator do
      destination File.expand_path("../../tmp", __FILE__)

      before(:each) do
        prepare_destination
      end

      after(:each) do
        FileUtils.rm_rf("spec/generators/tmp")
      end

      describe "Add migrations" do
        it "Add all" do
          run_generator
          expect(File).to exist("#{destination_root}/db/migrate")
          
          migrates = Dir.glob("#{destination_root}/db/migrate/*")
          
          expect(migrates.any? { |m| m.include?("social_framework_users.rb") }).to be(true)
          expect(migrates.any? { |m| m.include?("social_framework_edges.rb") }).to be(true)
          expect(migrates.any? { |m| m.include?("social_framework_relationships.rb") }).to be(true)
          expect(migrates.any? { |m| m.include?("social_framework_edge_relationships.rb") }).to be(true)
        end

        it "Add specific migrations" do
          run_generator %w(-m user edges)
          expect(File).to exist("#{destination_root}/db/migrate")

          migrates = Dir.glob("#{destination_root}/db/migrate/*")
          
          expect(migrates.any? { |m| m.include?("social_framework_users.rb") }).to be(true)
          expect(migrates.any? { |m| m.include?("social_framework_edges.rb") }).to be(true)
          expect(migrates.any? { |m| m.include?("social_framework_relationships.rb") }).to be(false)
          expect(migrates.any? { |m| m.include?("social_framework_edge_relationships.rb") }).to be(false)
        end

        it "Parameter invalid" do
          run_generator %w(-m invalid)
          expect(File).not_to exist("#{destination_root}/db/migrate")
        end
      end
    end
  end
end
