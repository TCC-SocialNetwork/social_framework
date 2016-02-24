require 'rails_helper'

module SocialFramework
  RSpec.describe User, type: :model do
    describe "Get login" do
      it "When has just email" do
        user = build(:user, username: "")
        expect(user.login).to eq("user@email.com") 
      end

      it "When has just username" do
        user = build(:user, email: "")
        expect(user.login).to eq("user") 
      end

      it "When has just login" do
        user = build(:user, login: "user_login", username: "", email: "")
        expect(user.login).to eq("user_login") 
      end

      it "When has login, email and username" do
        user = build(:user, login: "user_login")
        expect(user.login).to eq("user_login")
      end
    end

    describe "Authentication" do
      it "When username is valid" do
        user = create(:user)
        expect(User.find_for_database_authentication({login: "user"})).to eq(user)
        expect(User.find_for_database_authentication({username: "user"})).to eq(user)
      end

      it "When email is valid" do
        user = create(:user)
        expect(User.find_for_database_authentication({login: "user@email.com"})).to eq(user)
        expect(User.find_for_database_authentication({email: "user@email.com"})).to eq(user)
      end

      it "When attributes are invalids" do
        user = create(:user)
        expect(User.find_for_database_authentication({login: "user_invalid"})).to eq(nil)
        expect(User.find_for_database_authentication({username: "user_invalid"})).to eq(nil)
        expect(User.find_for_database_authentication({login: "user_invalid@email.com"})).to eq(nil)
        expect(User.find_for_database_authentication({email: "user_invalid@email.com"})).to eq(nil)
      end
    end
  end
end
