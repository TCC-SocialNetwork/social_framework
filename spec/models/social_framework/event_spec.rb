require 'rails_helper'

module SocialFramework
  RSpec.describe Event, type: :model do
    before(:each) do
      @user1 = create(:user,username: "user1", email: "user1@mail.com")
      @user2 = create(:user,username: "user2", email: "user2@mail.com")
      @user3 = create(:user,username: "user3", email: "user3@mail.com")
    end

    describe "Invite" do
      it "When creator invite someone out of relationships" do
        start = DateTime.now
        event = @user1.schedule.create_event "Event Test", start

        result = event.invite @user1, @user2

        expect(result).to be_nil
        expect(@user2.schedule.events.count).to be(0)
      end

      it "When creator invite someone" do
        @user1.create_relationship @user2, "r1", true, true
        start = DateTime.now
        event = @user1.schedule.create_event "Event Test", start

        result = event.invite @user1, @user2

        expect(result).not_to be_nil
        expect(result.confirmed).to be(false)
        expect(result.role).to eq("participant")

        expect(@user2.schedule.events.count).to be(1)
      end

      it "When a not participant invite someone" do
        @user1.create_relationship @user2, "r1", true, true
        @user2.create_relationship @user3, "r1", true, true
        start = DateTime.now
        event = @user1.schedule.create_event "Event Test", start

        result = event.invite @user2, @user3

        expect(result).to be_nil

        expect(@user3.schedule.events.count).to be(0)
      end
    end
  end
end