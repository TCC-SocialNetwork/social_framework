require 'rails_helper'

module SocialFramework
  RSpec.describe Users::SessionsController, type: :controller do
    include Devise::TestHelpers
    routes {SocialFramework::Engine.routes}

    describe "Authentication with login or username" do
      user = User.create(username: "user1", email: "user1@email.com", password: "password")

      it "Authentication when login equals username" do
        request.env["devise.mapping"] = Devise.mappings[:user]
        post :create, user: {
          login: "user1", password: "password"
        }
        expect(response).to have_http_status(302)
      end

      it "Authentication when login equals email" do
        request.env["devise.mapping"] = Devise.mappings[:user]
        post :create, user: {
          login: "user1@email.com", password: "password"
        }
        expect(response).to have_http_status(302)
      end
    end
  end
end
