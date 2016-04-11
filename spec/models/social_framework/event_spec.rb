require 'rails_helper'

module SocialFramework
  RSpec.describe Event, type: :model do
    before(:each) do
      @user1 = create(:user,username: "user1", email: "user1@mail.com")
      @user2 = create(:user,username: "user2", email: "user2@mail.com")
      @user3 = create(:user,username: "user3", email: "user3@mail.com")

      start = DateTime.now
      @event = @user1.schedule.create_event "Event Test", start
    end

    describe "Invite" do
      it "When creator invite someone out of relationships" do
        result = @event.invite @user1, @user2

        expect(result).to be_nil
        expect(@user2.schedule.events.count).to be(0)
      end

      it "When creator invite someone" do
        @user1.create_relationship @user2, "r1", true, true

        result = @event.invite @user1, @user2

        expect(result).not_to be_nil
        expect(result.confirmed).to be(false)
        expect(result.role).to eq("participant")

        expect(@user2.schedule.events.count).to be(1)
      end

      it "When a not participant invite someone" do
        @user1.create_relationship @user2, "r1", true, true
        @user2.create_relationship @user3, "r1", true, true
        result = @event.invite @user2, @user3

        expect(result).to be_nil
        expect(@user3.schedule.events.count).to be(0)
      end

      it "When a simple participant invite someone" do
        @user1.create_relationship @user2, "r1", true, true
        @user2.create_relationship @user3, "r1", true, true

        @event.invite @user1, @user2
        result = @user2.schedule.confirm_event(@event)

        expect(result).to be(true)

        result = @event.invite @user2, @user3

        expect(result).to be_nil
        expect(@user3.schedule.events).to be_empty
      end

      it "When an administrator invite someone" do
        @user1.create_relationship @user2, "r1", true, true
        @user2.create_relationship @user3, "r1", true, true

        @event.invite @user1, @user2
        @user2.schedule.confirm_event(@event)
        result = @event.make_administrator(@user1, @user2)

        expect(result).to be(true)

        result = @event.invite @user2, @user3

        expect(result).not_to be_nil
        expect(@user3.schedule.events.count).to be(1)
        expect(result.confirmed).to be(false)
        expect(result.role).to eq("participant")
      end
    end

    describe "Make administrator" do
      it "When creator try make administrator" do
        @user1.create_relationship @user2, "r1", true, true
        @user2.create_relationship @user3, "r1", true, true

        @event.invite @user1, @user2
        @user2.schedule.confirm_event(@event)
        result = @event.make_administrator(@user1, @user2)

        expect(result).to be(true)
        participant = ParticipantEvent.find_by_event_id_and_schedule_id(@event.id, @user2.schedule.id)
        expect(participant.role).to eq("admin")
      end

      it "When an administrator try make creator as administrator" do
        @user1.create_relationship @user2, "r1", true, true
        @user2.create_relationship @user3, "r1", true, true

        @event.invite @user1, @user2
        @user2.schedule.confirm_event(@event)
        @event.make_administrator(@user1, @user2)

        result = @event.make_administrator(@user2, @user1)
        expect(result).to be(false)

        participant = ParticipantEvent.find_by_event_id_and_schedule_id(@event.id, @user1.schedule.id)
        expect(participant.role).to eq("creator")
      end

      it "When a simple participant try make administrator" do
        @user1.create_relationship @user2, "r1", true, true
        @user1.create_relationship @user3, "r1", true, true

        @event.invite @user1, @user2
        @event.invite @user1, @user3
        @user2.schedule.confirm_event(@event)
        @user3.schedule.confirm_event(@event)
        
        result = @event.make_administrator(@user2, @user3)
        expect(result).to be(false)

        participant = ParticipantEvent.find_by_event_id_and_schedule_id(@event.id, @user3.schedule.id)
        expect(participant.role).to eq("participant")
      end
    end
  end
end