require 'rails_helper'

module SocialFramework
  RSpec.describe Schedule, type: :model do
    before(:each) do
      @user1 = create(:user)
      @user2 = create(:user2)

      locations = [{latitude: -15.792740000000002, longitude: -47.876360000000005},
                  {latitude: -15.792520000000001, longitude: -47.876900000000006}]

      @route = @user1.create_route("route", 63, locations)
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

    describe "Get ParticipantEvent" do
      it "When pass a nil event" do
        result = @user1.schedule.send(:get_participant_event, nil)
        expect(result).to be_nil
      end

      it "When user are not a participant event" do
        event = @user1.schedule.create_event("Event Test", DateTime.now)
        result = @user2.schedule.send(:get_participant_event, event)

        expect(result).to be_nil
      end

      it "When user are a participant event" do
        event = @user1.schedule.create_event("Event Test", DateTime.now)
        result = @user1.schedule.send(:get_participant_event, event)

        expect(result).not_to be_nil
        expect(result.event).to eq(event)
        expect(result.schedule).to eq(@user1.schedule)
      end
    end

    describe "Check disponibility" do
      it "When not exist event" do
        start = DateTime.now
        events = @user1.schedule.events_in_period start
        expect(events).to be_empty
      end

      it "When not exist event and pass duration" do
        start = DateTime.now
        events = @user1.schedule.events_in_period start, 2.hours
        expect(events).to be_empty
      end

      it "When not exist disponibility" do
        start = DateTime.new(2016, 01, 01, 14, 0, 0)
        @user1.schedule.create_event "Event Test", start, 2.hours

        start = DateTime.new(2016, 01, 01, 13, 0, 0)
        events = @user1.schedule.events_in_period start, (start + 2.hours)
        expect(events).not_to be_empty

        start = DateTime.new(2016, 01, 01, 13, 0, 0)
        events = @user1.schedule.events_in_period start, (start + 5.hours)
        expect(events).not_to be_empty

        start = DateTime.new(2016, 01, 01, 10, 0, 0)
        events = @user1.schedule.events_in_period start, (start + 2.hours)
        expect(events).to be_empty

        start = DateTime.new(2016, 01, 01, 12, 0, 0)
        events = @user1.schedule.events_in_period start, (start + 2.hours)
        expect(events).to be_empty

        start = DateTime.new(2016, 01, 01, 14, 0, 0)
        events = @user1.schedule.events_in_period start, (start + 2.hours)
        expect(events).not_to be_empty

        start = DateTime.new(2016, 01, 01, 15, 0, 0)
        events = @user1.schedule.events_in_period start, (start + 30.minutes)
        expect(events).not_to be_empty

        start = DateTime.new(2016, 01, 01, 15, 0, 0)
        events = @user1.schedule.events_in_period start, (start + 2.hours)
        expect(events).not_to be_empty

        start = DateTime.new(2016, 01, 01, 16, 0, 0)
        events = @user1.schedule.events_in_period start, (start + 2.hours)
        expect(events).to be_empty

        start = DateTime.new(2016, 01, 01, 17, 0, 0)
        events = @user1.schedule.events_in_period start, (start + 2.hours)
        expect(events).to be_empty
      end

      it "When exist multiple events" do
        start = DateTime.new(2016, 01, 01, 14, 0, 0)
        @user1.schedule.create_event "Event Test", start, 2.hours

        start = DateTime.new(2016, 01, 01, 16, 0, 0)
        @user1.schedule.create_event "Event Test", start, 2.hours

        start = DateTime.new(2016, 01, 01, 18, 0, 0)
        @user1.schedule.create_event "Event Test", start, 2.hours

        start = DateTime.new(2016, 01, 01, 14, 0, 0)
        events = @user1.schedule.events_in_period start
        expect(events.count).to be(3)

        start = DateTime.new(2016, 01, 01, 14, 0, 0)
        events = @user1.schedule.events_in_period start, start + 3.hours
        expect(events.count).to be(2)

        start = DateTime.new(2016, 01, 01, 14, 0, 0)
        events = @user1.schedule.events_in_period start, start + 5.hours
        expect(events.count).to be(3)
      end
    end

    describe "Confirm event" do
      before(:each) do
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

      it "When event has route" do
        expect(@event.route).to be_nil
        @event.add_route(@user1, @route)
        @event.invite(@user1, @user2)

        expect(@event.route.users.count).to be(1)
        @user2.schedule.confirm_event(@event)

        expect(@event.route.users.count).to be(2)
        expect(@event.route.users.include? @user1).to be(true)
      end
    end

    describe "Remove events" do
      before(:each) do
        @start = DateTime.now
        @event = @user1.schedule.create_event "Event Test", @start
        @user1.create_relationship(@user2, "r1", true, true)
        @event.invite(@user1, @user2)
        @user2.schedule.confirm_event(@event)
      end

      it "When creator try remove" do
        expect(@user1.schedule.events.count).to be(1)
        expect(@user2.schedule.events.count).to be(1)

        @user1.schedule.remove_event(@event)

        expect(@user1.schedule.events).to be_empty
        expect(@user2.schedule.events).to be_empty
      end

      it "When not creator try remove" do
        expect(@user1.schedule.events.count).to be(1)
        expect(@user2.schedule.events.count).to be(1)

        @user2.schedule.remove_event(@event)

        expect(@user1.schedule.events.count).to be(1)
        expect(@user2.schedule.events.count).to be(1)
      end

      it "When event has route" do
        @event.add_route(@user1, @route)
        @user1.schedule.remove_event(@event)

        expect(@user1.routes).to be_empty
        expect(@user2.routes).to be_empty
      end
    end

    describe "Exit event" do
      before(:each) do
        @start = DateTime.now
        @event = @user1.schedule.create_event "Event Test", @start
        @user1.create_relationship(@user2, "r1", true, true)
        @event.invite(@user1, @user2)
        @user2.schedule.confirm_event(@event)
      end

      it "When a participant try exit" do
        expect(@event.participant_events.count).to be(2)

        @user2.schedule.exit_event(@event)

        expect(@event.participant_events.count).to be(1)
      end

      it "When creator try exit" do
        expect(@event.participant_events.count).to be(2)

        @user1.schedule.exit_event(@event)

        expect(@event.participant_events.count).to be(2)
      end

      it "When event has route" do
        @event.add_route(@user1, @route)
        expect(@event.route.users.count).to be(2)

        @user2.schedule.exit_event(@event)

        expect(@event.participant_events.count).to be(1)
        expect(@user2.schedule.events).to be_empty
        expect(@event.route.users.count).to be(1)
        expect(@user2.routes).to be_empty
      end
    end

    describe "Enter in an event" do
      it "When event is nil" do
        result = @user1.schedule.enter_in_event(nil)
        expect(result).to be_nil
      end

      it "When event is particular" do
        start = DateTime.now
        event = @user1.schedule.create_event("Event Test", start, 1.hour, "Event description", true)
        result = @user2.schedule.enter_in_event(event)
        expect(result).to be_nil
      end

      it "When user already have an event in same period" do
        start = DateTime.now
        event = @user1.schedule.create_event("Event Test", start)
        @user2.schedule.create_event("Event Test", start)
        
        result = @user2.schedule.enter_in_event(event)
        expect(result).to be_nil
      end

      it "When user already are in event" do
        start = DateTime.now
        event = @user1.schedule.create_event("Event Test", start)
        @user1.create_relationship(@user2, "r1", true, true)
        event.invite(@user1, @user2)
        @user2.schedule.confirm_event(event)

        result = @user2.schedule.enter_in_event(event)
        expect(result).to be_nil
      end

      it "When event is public" do
        start = DateTime.now
        event = @user1.schedule.create_event("Event Test", start)
        participant_event = ParticipantEvent.find_by_event_id_and_schedule_id(event.id, @user2.schedule.id)

        expect(participant_event).to be_nil

        @user2.schedule.enter_in_event(event)
        participant_event = ParticipantEvent.find_by_event_id_and_schedule_id(event.id, @user2.schedule.id)

        expect(participant_event).not_to be_nil        
        expect(participant_event.event).to eq(event)
        expect(participant_event.schedule).to eq(@user2.schedule)
      end

      it "When event has route" do
        start = DateTime.now
        event = @user1.schedule.create_event("Event Test", start)
        event.add_route(@user1, @route)

        expect(event.route.users.count).to be(1)
        @user2.schedule.enter_in_event(event)

        expect(event.route.users.count).to be(2)
        expect(@user2.routes.count).to be(1)
        expect(@user2.routes.include? @route).to be(true)
      end
    end

    describe "Relations user route" do
      before(:each) do
        start = DateTime.now
        @event = @user1.schedule.create_event "Event Test", start
      end

      it "When pass invalid params" do
        result = @user1.schedule.send(:relation_user_route, nil)
        expect(result).to be_nil
      end

      it "When pass event without route" do
        result = @user1.schedule.send(:relation_user_route, @event)
        expect(result).to be_nil
      end

      it "When pass event with route" do
        @event.add_route(@user1, @route)

        result = @user2.schedule.send(:relation_user_route, @event)
        expect(result).to be(true)
        expect(@user2.routes.include? @route).to be(true)
      end
    end
  end
end
