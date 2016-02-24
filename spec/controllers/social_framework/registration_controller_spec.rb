require 'rails_helper'

module SocialFramework
  RSpec.describe Users::RegistrationsController, type: :controller do
  	include Devise::TestHelpers
    routes {SocialFramework::Engine.routes}

    describe "Permit username attribute" do
      it "Sign up with username" do
        request.env["devise.mapping"] = Devise.mappings[:user]
        
        post :create, user: {
          username: "user", email: "user@email.com", password: "password", password_confirmation: "password"
        }

        expect(response).to have_http_status(302)
      end

      it "Account update with username" do
        request.env["devise.mapping"] = Devise.mappings[:user]
        
        user = create(:user)
        sign_in user
        put :update, user: {
          username: "user1", email: "user1@email.com", current_password: "password"
        }

        expect(response).to have_http_status(302)
      end
    end
  end
end
