require 'rails_helper'

module SocialFramework
  RSpec.describe Schedule, type: :model do
    before(:each) do
      @user = create(:user)
    end

    describe "Create events" do
      it "When use default params" do
        expect(Event.count).to be(0)
        start = DateTime.now
        event = @user.schedule.create_event("Event Test", start)
        expect(Event.count).to be(1)

        expect(event).not_to be_nil
        expect(event.title).to eq("Event Test")
        expect(event.description).to eq("")
        expect(event.particular).to be(false)
        expect(event.start.to_datetime).to eq(start)
        expect(event.finish.to_datetime).to eq(start.end_of_day)

        expect(event.schedules.count).to be(1)
        expect(event.schedules.first).to eq(@user.schedule)
        expect(event.participant_events.count).to be(1)
        expect(event.participant_events.first.role).to eq("creator")
        expect(event.participant_events.first.confirmed).to be(true)
      end

      it "When pass duration" do
        start = DateTime.now
        event = @user.schedule.create_event("Event Test", start, 1.hour)

        expect(event.start.to_datetime).to eq(start)
        expect(event.finish.to_datetime).to eq(start + 1.hour)
      end

      it "When pass all params" do
        start = DateTime.now
        event = @user.schedule.create_event("Event Test", start, 1.day, "Event description", true)

        expect(event.title).to eq("Event Test")
        expect(event.description).to eq("Event description")
        expect(event.particular).to be(true)
        expect(event.start.to_datetime).to eq(start)
        expect(event.finish.to_datetime).to eq(start + 1.day)
      end

      it "When pass invalid duration" do
        start = DateTime.now

        event = @user.schedule.create_event("Event Test", start, :invalid)
        expect(event).to be_nil

        event = @user.schedule.create_event("Event Test", start, 1)
        expect(event).to be_nil
      end
    end
  end
end
