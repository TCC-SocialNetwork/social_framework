require 'rails_helper'

module SocialFramework
  RSpec.describe User, type: :model do
    describe "Get login" do
      it "When has just email" do
        user = User.new(email: "user@email.com")

        expect(user.login).to eq("user@email.com") 
      end

      it "When has just username" do
        user = User.new(username: "user")

        expect(user.login).to eq("user") 
      end

      it "When has just login" do
        user = User.new(login: "user_login")

        expect(user.login).to eq("user_login") 
      end

      it "When has login, email and username" do
        user = User.new(login: "user_login", email: "user@email.com", username: "user")

        expect(user.login).to eq("user_login")
      end
    end

    describe "Authentication" do
      user = User.create(username: "user2", email: "2user@email.com", password: "password")

      it "When username is valid" do
        expect(User.find_for_database_authentication({login: "user2"})).to eq(user)
        expect(User.find_for_database_authentication({username: "user2"})).to eq(user)
      end

      it "When email is valid" do
        expect(User.find_for_database_authentication({login: "2user@email.com"})).to eq(user)
        expect(User.find_for_database_authentication({email: "2user@email.com"})).to eq(user)
      end

      it "When attributes are invalids" do
        expect(User.find_for_database_authentication({login: "user_invalid"})).to eq(nil)
        expect(User.find_for_database_authentication({username: "user_invalid"})).to eq(nil)
        expect(User.find_for_database_authentication({login: "user_invalid@email.com"})).to eq(nil)
        expect(User.find_for_database_authentication({email: "user_invalid@email.com"})).to eq(nil)
      end
    end
  end
end
