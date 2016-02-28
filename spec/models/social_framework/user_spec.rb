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

    describe "Follow" do
      before(:each) do
        @user = create(:user)
        @user2 = create(:user2)

      end
      it "When an user follow an other user" do
        @user.follow(@user2)
        expect(@user.edges.count).to eq(1)
        expect(@user.edges.first.relationships.count).to eq(1)
        expect(@user.edges.first.relationships.first.label).to eq("following")
        expect(@user.edges.first.edge_relationships.first.active).to be(true)
      end

      it "When the relationship should be inactive" do
        @user.follow(@user2, false)
        expect(@user.edges.first.relationships.first.label).to eq("following")
        expect(@user.edges.first.edge_relationships.first.active).to be(false)
      end
    end

    describe "Unfollow" do
      before(:each) do
        @user = create(:user)
        @user2 = create(:user2)
      end
      it "When the an user unfollow other user" do
        @user.follow(@user2)
        
        @user.unfollow(@user2)
        expect(@user.edges).to be_empty
      end

      it "When an user unfollow other user with multiple relationships" do
        @user.follow(@user2)
        relationship = create(:relationship)
        @user.edges.first.relationships << relationship
        expect(@user.edges.first.relationships.count).to eq(2)
        @user.unfollow(@user2)
        expect(@user.edges.first.relationships.count).to eq(1)
      end
    end

    describe "Add friend" do
      before(:each) do
        @user = create(:user)
        @user2 = create(:user2)
      end

      it "When an user add a new friend" do
        @user.add_friend(@user2)
        expect(@user.edges.count).to eq(1)
        expect(@user.edges.first.relationships.count).to eq(1)
        expect(@user.edges.first.relationships.first.label).to eq("friend")
        expect(@user.edges.first.edge_relationships.first.active).to be(false)

        expect(@user2.edges.count).to eq(1)
        expect(@user2.edges.first.relationships.count).to eq(1)
        expect(@user2.edges.first.relationships.first.label).to eq("friend")
        expect(@user2.edges.first.edge_relationships.first.active).to be(false)
      end

      it "When two users try add each other as a friend" do
        @user.add_friend(@user2)
        expect(@user.edges.count).to eq(1)
        expect(@user.edges.first.relationships.count).to eq(1)
        expect(@user2.edges.count).to eq(1)
        expect(@user2.edges.first.relationships.count).to eq(1)

        @user2.add_friend(@user)
        expect(@user.edges.count).to eq(1)
        expect(@user.edges.first.relationships.count).to eq(1)
        expect(@user2.edges.count).to eq(1)
        expect(@user2.edges.first.relationships.count).to eq(1)
      end

      it "When the relationship should be active" do
        @user.add_friend(@user2, true)
        
        expect(@user.edges.first.relationships.first.label).to eq("friend")
        expect(@user.edges.first.edge_relationships.first.active).to be(true)
        
        expect(@user2.edges.first.relationships.first.label).to eq("friend")
        expect(@user2.edges.first.edge_relationships.first.active).to be(true)
      end
    end

    describe "Confirm friendship" do
      before(:each) do
        @user = create(:user)
        @user2 = create(:user2)
      end

      it "When friendship is invalid" do
        result = @user.confirm_friendship(@user2)
        expect(result).to be_nil

        result = @user.confirm_friendship(nil)
        expect(result).to be_nil

        result = @user.confirm_friendship(@user)
        expect(result).to be_nil
      end

      it "When friendship is valid" do
        @user.add_friend(@user2)
        @user2.confirm_friendship(@user)

        expect(@user.edges.count).to eq(1)
        expect(@user.edges.first.relationships.count).to eq(1)
        expect(@user.edges.first.edge_relationships.first.active).to be(true)
        expect(@user2.edges.count).to eq(1)
        expect(@user2.edges.first.relationships.count).to eq(1)
        expect(@user2.edges.first.edge_relationships.first.active).to be(true)
      end
    end
  end
end
