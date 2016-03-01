require 'rails_helper'

module SocialFramework
  RSpec.describe UserHelper, type: :helper do
    describe "Delete relationship" do
      before(:each) do
        @user = create(:user)
        @user2 = create(:user2)
      end
      it "When the relationship exist" do
        @user.create_relationship(@user2, "new_relationship")
        
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
        @user.create_relationship(@user2, "new_relationship")
        @user.create_relationship(@user2, "new_relationship2")
        expect(@user.edges.first.relationships.count).to eq(2)

        UserHelper.delete_relationship(@user, @user2, "new_relationship")
        expect(@user.edges.first.relationships.count).to eq(1)
      end
    end
  end
end
