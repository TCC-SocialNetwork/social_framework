require 'rails_helper'

module SocialFramework
  RSpec.describe Schedule, type: :model do
    before(:each) do
      @user1 = create(:user)
    end

    describe "Create events" do
      it "When use default params" do
        expect(Event.count).to be(0)
        start = DateTime.now
        event = @user1.schedule.create_event("Event Test", start)
        expect(Event.count).to be(1)

        expect(event).not_to be_nil
        expect(event.title).to eq("Event Test")
        expect(event.description).to eq("")
        expect(event.particular).to be(false)
        expect(event.start.to_datetime).to eq(start)
        expect(event.finish.to_datetime).to eq(start.end_of_day)

        expect(event.schedules.count).to be(1)
        expect(event.schedules.first).to eq(@user1.schedule)
        expect(event.participant_events.count).to be(1)
        expect(event.participant_events.first.role).to eq("creator")
        expect(event.participant_events.first.confirmed).to be(true)
      end

      it "When pass duration" do
        start = DateTime.now
        event = @user1.schedule.create_event("Event Test", start, 1.hour)

        expect(event.start.to_datetime).to eq(start)
        expect(event.finish.to_datetime).to eq(start + 1.hour)
      end

      it "When pass all params" do
        start = DateTime.now
        event = @user1.schedule.create_event("Event Test", start, 1.day, "Event description", true)

        expect(event.title).to eq("Event Test")
        expect(event.description).to eq("Event description")
        expect(event.particular).to be(true)
        expect(event.start.to_datetime).to eq(start)
        expect(event.finish.to_datetime).to eq(start + 1.day)
      end

      it "When pass invalid duration" do
        start = DateTime.now

        event = @user1.schedule.create_event("Event Test", start, :invalid)
        expect(event).to be_nil

        event = @user1.schedule.create_event("Event Test", start, 1)
        expect(event).to be_nil

        event = @user1.schedule.create_event("Event Test", start, -1.hour)
        expect(event).to be_nil

        event = @user1.schedule.create_event("Event Test", start, 0.hour)
        expect(event).to be_nil
      end

      it "When there is not disponibility" do
        start = DateTime.now
        event = @user1.schedule.create_event("Event Test", start, 1.hour)

        expect(event.start.to_datetime).to eq(start)
        expect(event.finish.to_datetime).to eq(start + 1.hour)
        expect(@user1.schedule.events.count).to be(1)

        event = @user1.schedule.create_event("Event Test", start, 1.hour)

        expect(event).to be_nil
        expect(@user1.schedule.events.count).to be(1)
      end
    end

    describe "Finish date" do
      it "When duration is nil" do
        start = DateTime.now
        finish = @user1.schedule.send(:set_finish_date, start, nil)

        expect(finish).to eq(start.end_of_day)
      end

      it "When duration is valid" do
        start = DateTime.now
        finish = @user1.schedule.send(:set_finish_date, start, 1.hour)

        expect(finish).to eq(start + 1.hour)
      end

      it "When duration is invalid" do
        start = DateTime.now
        finish = @user1.schedule.send(:set_finish_date, start, -1.hour)

        expect(finish).to be_nil
      end
    end

    describe "Check disponibility" do
      it "When not exist event" do
        start = DateTime.now
        disponibility = @user1.schedule.check_disponibility start
        expect(disponibility).to be(true) 
      end

      it "When not exist event and pass duration" do
        start = DateTime.now
        disponibility = @user1.schedule.check_disponibility start, 2.hours
        expect(disponibility).to be(true) 
      end

      it "When not exist disponibility" do
        start = DateTime.new(2016, 01, 01, 14, 0, 0)
        @user1.schedule.create_event "Event Test", start, 2.hours

        start = DateTime.new(2016, 01, 01, 13, 0, 0)
        disponibility = @user1.schedule.check_disponibility start, (start + 2.hours)
        expect(disponibility).to be(false)

        start = DateTime.new(2016, 01, 01, 13, 0, 0)
        disponibility = @user1.schedule.check_disponibility start, (start + 5.hours)
        expect(disponibility).to be(false)

        start = DateTime.new(2016, 01, 01, 10, 0, 0)
        disponibility = @user1.schedule.check_disponibility start, (start + 2.hours)
        expect(disponibility).to be(true)

        start = DateTime.new(2016, 01, 01, 12, 0, 0)
        disponibility = @user1.schedule.check_disponibility start, (start + 2.hours)
        expect(disponibility).to be(true)

        start = DateTime.new(2016, 01, 01, 14, 0, 0)
        disponibility = @user1.schedule.check_disponibility start, (start + 2.hours)
        expect(disponibility).to be(false)

        start = DateTime.new(2016, 01, 01, 15, 0, 0)
        disponibility = @user1.schedule.check_disponibility start, (start + 30.minutes)
        expect(disponibility).to be(false)

        start = DateTime.new(2016, 01, 01, 15, 0, 0)
        disponibility = @user1.schedule.check_disponibility start, (start + 2.hours)
        expect(disponibility).to be(false)

        start = DateTime.new(2016, 01, 01, 16, 0, 0)
        disponibility = @user1.schedule.check_disponibility start, (start + 2.hours)
        expect(disponibility).to be(true)

        start = DateTime.new(2016, 01, 01, 17, 0, 0)
        disponibility = @user1.schedule.check_disponibility start, (start + 2.hours)
        expect(disponibility).to be(true)
      end
    end

    describe "Confirm event" do
      before(:each) do
        @user2 = create(:user, username: "user2", email: "user2@email.com")

        @start = DateTime.now
        @event = @user1.schedule.create_event "Event Test", @start
        @user1.create_relationship(@user2, "r1", true, true)
      end

      it "When not exist an invitation" do
        result = @user2.schedule.confirm_event(@event)
        expect(result).to be(false)
      end

      it "When exist an invitation" do
        @event.invite(@user1, @user2)

        result = @user2.schedule.confirm_event(@event)
        expect(result).to be(true)

        participant = ParticipantEvent.find_by_event_id_and_schedule_id(@event.id, @user2.schedule.id)
        expect(participant.role).to eq("participant")
        expect(participant.confirmed).to be(true)
      end

      it "When not exist disponibility" do
        @user2.schedule.create_event "Event Test", @start
        @event.invite(@user1, @user2)

        result = @user2.schedule.confirm_event(@event)
        expect(result).to be(false)

        participant = ParticipantEvent.find_by_event_id_and_schedule_id(@event.id, @user2.schedule.id)
        expect(participant.role).to eq("participant")
        expect(participant.confirmed).to be(false)
      end
    end
  end
end
