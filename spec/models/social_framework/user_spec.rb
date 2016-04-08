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
        expect(@user.edges.first.label).to eq("new_relationship")
        expect(@user.edges.first.active).to be(false)
        expect(@user.edges.first.bidirectional).to be(true)
      end

      it "When is active" do
        @user.create_relationship(@user2, "new_relationship", true, true)
        expect(@user.edges.first.label).to eq("new_relationship")
        expect(@user.edges.first.active).to be(true)
        expect(@user.edges.first.bidirectional).to be(true)
      end

      it "When is unidirectional" do
        @user.create_relationship(@user2, "new_relationship", false, true)
        expect(@user.edges.first.label).to eq("new_relationship")
        expect(@user.edges.first.active).to be(true)
        expect(@user.edges.first.bidirectional).to be(false)
      end

      it "When the two users try create relationship" do
        @user.create_relationship(@user2, "new_relationship")
        @user2.create_relationship(@user, "new_relationship")

        expect(@user.edges.count).to eq(1)
        expect(@user.edges.first.label).to eq("new_relationship")
        expect(@user2.edges.count).to eq(1)
        expect(@user2.edges.first.label).to eq("new_relationship")

        expect(@user.edges.first.origin).to eq(@user)
        expect(@user.edges.first.destiny).to eq(@user2)
        expect(@user2.edges.first.origin).to eq(@user)
        expect(@user2.edges.first.destiny).to eq(@user2)
      end

      it "When already exist an edge" do
        @user.create_relationship(@user2, "new_relationship")
        @user.create_relationship(@user2, "other_relationship")

        expect(@user.edges.count).to eq(2)
        expect(@user.edges.first.label).to eq("new_relationship")
        expect(@user.edges.last.label).to eq("other_relationship")

        expect(@user2.edges.count).to eq(2)
        expect(@user2.edges.first.label).to eq("new_relationship")
        expect(@user2.edges.last.label).to eq("other_relationship")
      end
    end

    describe "Remove relationships" do
      before(:each) do
        @user = create(:user)
        @user2 = create(:user2)
      end
      it "When the user is nil" do
        result = @user.remove_relationship(nil, "new_relationship")
        expect(result).to be_nil
      end

      it "When the relationship not exist" do
        result = @user.remove_relationship(@user2, "new_relationship")
        expect(result).to be_nil
      end

      it "When delete a relationship with same user" do
        result = @user.remove_relationship(@user, "new_relationship")
        expect(result).to be_nil
      end

      it "When the an user remove a relationship" do
        @user.create_relationship(@user2, "new_relationship")
        expect(@user.edges.count).to eq(1)

        @user.remove_relationship(@user2, "new_relationship")
        expect(@user.edges).to be_empty
      end

      it "When exist multiple relationships" do
        @user.create_relationship(@user2, "new_relationship")
        @user.create_relationship(@user2, "other_relationship")
        expect(@user.edges.count).to eq(2)

        @user.remove_relationship(@user2, "new_relationship")
        expect(@user.edges.count).to eq(1)
        expect(@user.edges.first.label).to eq("other_relationship")
      end
    end

    describe "Confirm relationship" do
      before(:each) do
        @user = create(:user)
        @user2 = create(:user2)
      end

      it "When relationship is invalid" do
        result = @user.confirm_relationship(@user2, "new_relationship")
        expect(result).to be(false)

        result = @user.confirm_relationship(nil, "new_relationship")
        expect(result).to be(false)

        result = @user.confirm_relationship(@user, "new_relationship")
        expect(result).to be(false)
      end

      it "When relationship is valid" do
        @user.create_relationship(@user2, "new_relationship")
        @user2.confirm_relationship(@user, "new_relationship")

        expect(@user.edges.count).to eq(1)
        expect(@user.edges.first.active).to be(true)
        expect(@user.edges.first.bidirectional).to be(true)
        expect(@user2.edges.count).to eq(1)
        expect(@user2.edges.first.active).to be(true)
        expect(@user2.edges.first.bidirectional).to be(true)
      end

      it "When user suggested relationship try confirm" do
        @user.create_relationship(@user2, "new_relationship")
        @user.confirm_relationship(@user2, "new_relationship")

        expect(@user.edges.first.active).to be(false)
        expect(@user2.edges.first.active).to be(false)
      end
    end

    describe "Get users from relationships" do
      before(:each) do
        @user1 = create(:user,username: "user1", email: "user1@mail.com")
        @user2 = create(:user,username: "user2", email: "user2@mail.com")
        @user3 = create(:user,username: "user3", email: "user3@mail.com")
        @user4 = create(:user,username: "user4", email: "user4@mail.com")
        @user5 = create(:user,username: "user5", email: "user5@mail.com")
        @user6 = create(:user,username: "user6", email: "user6@mail.com")

        @user1.create_relationship(@user2, "r1")
        @user1.create_relationship(@user3, "r1")
        @user1.create_relationship(@user4, "r1")
        @user1.create_relationship(@user6, "r2")
        @user5.create_relationship(@user1, "r1")
      end

      it "When not exist specified relationships" do
        result = @user1.relationships("invalid")
        expect(result).to be_empty
      end

      it "When not exist active relationships" do
        result = @user1.relationships("r1")
        expect(result).to be_empty
      end

      it "When get all inactive from specific relationship" do
        result = @user1.relationships("r1", false)
        expect(result.count).to be(4)

        result = @user1.relationships("r2", false)
        expect(result.count).to be(1)
      end

      it "When get all inactive relationships" do
        result = @user1.relationships("all", false)
        expect(result.count).to be(5)
      end

      it "When get all inactive relationships created by me" do
        result = @user1.relationships("r1", false, "self")
        expect(result.count).to be(3)
      end

      it "When get all inactive relationships created by others" do
        result = @user1.relationships("r1", false, "other")
        expect(result.count).to be(1)
      end

      it "When exist active relationships" do
        @user2.confirm_relationship(@user1, "r1")
        
        result = @user1.relationships("r1")
        expect(result.count).to be(1)
      end
    end

    describe "Get schedule" do
      before(:each) do
        @user = create(:user)
      end

      it "When user dont't have schedule" do
        expect(Schedule.count).to be(0)
        expect(@user.schedule.user).to eq(@user)
        expect(Schedule.count).to be(1)
      end

      it "When user already have schedule" do
        Schedule.create(user: @user)

        expect(Schedule.count).to be(1)
        expect(@user.schedule.user).to eq(@user)
        expect(Schedule.count).to be(1)
      end

      it "When user is not created" do
        expect(Schedule.count).to be(0)
        expect(User.new.schedule).to be(nil)
        expect(Schedule.count).to be(0)
      end
    end
  end
end
