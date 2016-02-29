require 'rails_helper'

module SocialFramework
  RSpec.describe UserHelper, type: :helper do
    describe "Create relationships" do
      before(:each) do
        @user = create(:user)
        @user2 = create(:user2)

      end
      it "When create with origin or destiny nil" do
        UserHelper.create_relationship(@user, nil, "")
        expect(@user.edges).to be_empty

        UserHelper.create_relationship(nil, @user2, "")
        expect(@user.edges).to be_empty

        UserHelper.create_relationship(nil, nil, "")
        expect(@user.edges).to be_empty
      end

      it "When an user create relationship himself" do
        UserHelper.create_relationship(@user, @user, "")
        expect(@user.edges).to be_empty
      end

      it "When create a valid relationship" do
        UserHelper.create_relationship(@user, @user2, "new_relationship")
        expect(@user.edges.count).to eq(1)
        expect(@user.edges.first.relationships.count).to eq(1)
        expect(@user.edges.first.relationships.first.label).to eq("new_relationship")
        expect(@user.edges.first.edge_relationships.first.active).to be(false)
        expect(@user.edges.first.bidirectional).to be(true)
      end

      it "When create a valid relationship with attribute active true and bidirectional false" do
        UserHelper.create_relationship(@user, @user2, "new_relationship", true, false)
        expect(@user.edges.count).to eq(1)
        expect(@user.edges.first.relationships.count).to eq(1)
        expect(@user.edges.first.relationships.first.label).to eq("new_relationship")
        expect(@user.edges.first.edge_relationships.first.active).to be(true)
        expect(@user.edges.first.bidirectional).to be(false)
      end

      it "When an user try follow multiple times" do
        UserHelper.create_relationship(@user, @user2, "new_relationship")
        expect(@user.edges.count).to eq(1)
        expect(@user.edges.first.relationships.count).to eq(1)

        UserHelper.create_relationship(@user, @user2, "new_relationship")
        expect(@user.edges.count).to eq(1)
        expect(@user.edges.first.relationships.count).to eq(1)
      end
    end

    describe "Delete relationship" do
      before(:each) do
        @user = create(:user)
        @user2 = create(:user2)
      end
      it "When the relationship exist" do
        UserHelper.create_relationship(@user, @user2, "new_relationship")
        
        UserHelper.delete_relationship(@user, @user2, "new_relationship")
        expect(@user.edges).to be_empty
      end

      it "When the parameter is invalid" do
        result = UserHelper.delete_relationship(@user, nil, "new_relationship")
        expect(result).to be_nil

        result = UserHelper.delete_relationship(nil, @user2, "new_relationship")
        expect(result).to be_nil

        result = UserHelper.delete_relationship(nil, nil, "new_relationship")
        expect(result).to be_nil
      end

      it "When the relationship not exist" do
        result = UserHelper.delete_relationship(@user, @user2, "new_relationship")
        expect(result).to be_nil
      end

      it "When delete a relationship with same user" do
        result = UserHelper.delete_relationship(@user, @user, "new_relationship")
        expect(result).to be_nil
      end

      it "When multiple relationships" do
        UserHelper.create_relationship(@user, @user2, "new_relationship")
        UserHelper.create_relationship(@user, @user2, "new_relationship2")
        expect(@user.edges.first.relationships.count).to eq(2)

        UserHelper.delete_relationship(@user, @user2, "new_relationship")
        expect(@user.edges.first.relationships.count).to eq(1)
      end
    end
  end
end
