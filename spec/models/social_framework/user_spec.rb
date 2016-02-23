require 'rails_helper'

module SocialFramework
  RSpec.describe User, type: :model do
    it "get login when has just email" do
      user = User.new(email: "user@email.com")

      expect(user.login).to eq("user@email.com") 
    end

    it "get login when has just username" do
      user = User.new(username: "user")

      expect(user.login).to eq("user") 
    end

    it "get login when has just login" do
      user = User.new(login: "user_login")

      expect(user.login).to eq("user_login") 
    end

    it "get login when has login, email and username" do
      user = User.new(login: "user_login", email: "user@email.com", username: "user")

      expect(user.login).to eq("user_login")
    end

    it "login when username is valid" do
      user = User.create(username: "user", email: "user@email.com", password: "password")

      expect(User.find_for_database_authentication({login: "user"})).to eq(user)
      expect(User.find_for_database_authentication({username: "user"})).to eq(user)
    end

    it "login when email is valid" do
      user = User.create(username: "user", email: "user@email.com", password: "password")

      expect(User.find_for_database_authentication({login: "user@email.com"})).to eq(user)
      expect(User.find_for_database_authentication({email: "user@email.com"})).to eq(user)
    end

    it "login invalid" do
      user = User.create(username: "user", email: "user@email.com", password: "password")

      expect(User.find_for_database_authentication({login: "user_invalid"})).to eq(nil)
      expect(User.find_for_database_authentication({username: "user_invalid"})).to eq(nil)
      expect(User.find_for_database_authentication({login: "user_invalid@email.com"})).to eq(nil)
      expect(User.find_for_database_authentication({email: "user_invalid@email.com"})).to eq(nil)
    end

  end
end
