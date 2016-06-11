require 'rails_helper'

module SocialFramework
  RSpec.describe Users::SessionsController, type: :controller do
    include Devise::TestHelpers
    routes {SocialFramework::Engine.routes}

    describe "Authentication with login or username" do
      it "Authentication when login equals username" do
        user = create(:user)
        
        request.env["devise.mapping"] = Devise.mappings[:user]
        post :create, user: {
          login: "user", password: "password"
        }

        expect(response).to have_http_status(302)
      end

      it "Authentication when login equals email" do
        user = create(:user)
        
        request.env["devise.mapping"] = Devise.mappings[:user]
        post :create, user: {
          login: "user@email.com", password: "password"
        }

        expect(response).to have_http_status(302)
      end

      it "Logout" do
        user = create(:user)
        request.env["devise.mapping"] = Devise.mappings[:user]
        post :create, user: {
          login: "user@email.com", password: "password"
        }
        delete :destroy
        expect(response).to have_http_status(302)
      end
    end
  end
end
