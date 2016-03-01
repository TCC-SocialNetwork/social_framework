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

    describe "Create relationships" do
      before(:each) do
        @user = create(:user)
        @user2 = create(:user2)

      end
      it "When create with origin or destiny nil" do
        @user.create_relationship(nil, "")
        expect(@user.edges).to be_empty
      end

      it "When an user create relationship himself" do
        @user.create_relationship(@user, "")
        expect(@user.edges).to be_empty
      end

      it "When create a valid relationship" do
        @user.create_relationship(@user2, "new_relationship")
        expect(@user.edges.count).to eq(1)
        expect(@user.edges.first.relationships.count).to eq(1)
        expect(@user.edges.first.relationships.first.label).to eq("new_relationship")
        expect(@user.edges.first.edge_relationships.first.active).to be(false)
        expect(@user.edges.first.bidirectional).to be(true)
      end

      it "When is active" do
        @user.create_relationship(@user2, "new_relationship", true)
        expect(@user.edges.first.relationships.first.label).to eq("new_relationship")
        expect(@user.edges.first.edge_relationships.first.active).to be(true)
        expect(@user.edges.first.bidirectional).to be(true)
      end

      it "When is unidirectional" do
        @user.create_relationship(@user2, "new_relationship", true, false)
        expect(@user.edges.first.relationships.first.label).to eq("new_relationship")
        expect(@user.edges.first.edge_relationships.first.active).to be(true)
        expect(@user.edges.first.bidirectional).to be(false)
      end

      it "When the two users try create relationship" do
        @user.create_relationship(@user2, "new_relationship")
        @user2.create_relationship(@user, "new_relationship")

        expect(@user.edges.count).to eq(1)
        expect(@user.edges.first.relationships.first.label).to eq("new_relationship")
        expect(@user2.edges.count).to eq(1)
        expect(@user2.edges.first.relationships.first.label).to eq("new_relationship")

        expect(@user.edges.first.origin).to eq(@user)
        expect(@user.edges.first.destiny).to eq(@user2)
        expect(@user2.edges.first.origin).to eq(@user)
        expect(@user2.edges.first.destiny).to eq(@user2)
      end

      it "When already exist an edge" do
        @user.create_relationship(@user2, "new_relationship")
        @user.create_relationship(@user2, "other_relationship")

        expect(@user.edges.count).to eq(1)
        expect(@user.edges.first.relationships.count).to eq(2)
        expect(@user.edges.first.relationships.first.label).to eq("new_relationship")
        expect(@user.edges.first.relationships.last.label).to eq("other_relationship")

        expect(@user2.edges.count).to eq(1)
        expect(@user2.edges.first.relationships.count).to eq(2)
        expect(@user2.edges.first.relationships.first.label).to eq("new_relationship")
        expect(@user2.edges.first.relationships.last.label).to eq("other_relationship")
      end
    end

    describe "Unfollow" do
      before(:each) do
        @user = create(:user)
        @user2 = create(:user2)
      end
      it "When the an user unfollow other user" do
        @user.create_relationship(@user2, "following", true, false)
        
        @user.unfollow(@user2)
        expect(@user.edges).to be_empty
      end

      it "When an user unfollow other user with multiple relationships" do
        @user.create_relationship(@user2, "following", true, false)
        relationship = create(:relationship)
        @user.edges.first.relationships << relationship
        expect(@user.edges.first.relationships.count).to eq(2)
        @user.unfollow(@user2)
        expect(@user.edges.first.relationships.count).to eq(1)
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
        @user.create_relationship(@user2, "friend")
        @user2.confirm_friendship(@user)

        expect(@user.edges.count).to eq(1)
        expect(@user.edges.first.relationships.count).to eq(1)
        expect(@user.edges.first.edge_relationships.first.active).to be(true)
        expect(@user.edges.first.bidirectional).to be(true)
        expect(@user2.edges.count).to eq(1)
        expect(@user2.edges.first.relationships.count).to eq(1)
        expect(@user2.edges.first.edge_relationships.first.active).to be(true)
        expect(@user2.edges.first.bidirectional).to be(true)
      end

      it "When user suggested friendship try confirm" do
        @user.create_relationship(@user2, "friend")
        @user.confirm_friendship(@user2)

        expect(@user.edges.first.edge_relationships.first.active).to be(false)
        expect(@user2.edges.first.edge_relationships.first.active).to be(false)
      end
    end
  end
end
