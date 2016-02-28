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
        expect(@user.edges.first.edge_relationships.first.active).to be(true)
      end

      it "When create a valid relationship with attribute active false" do
        UserHelper.create_relationship(@user, @user2, "new_relationship", false)
        expect(@user.edges.count).to eq(1)
        expect(@user.edges.first.relationships.count).to eq(1)
        expect(@user.edges.first.relationships.first.label).to eq("new_relationship")
        expect(@user.edges.first.edge_relationships.first.active).to be(false)
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
  end
end
