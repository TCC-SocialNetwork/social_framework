require 'rails_helper'


module SocialFramework
  RSpec.describe ScheduleHelper, type: :helper do
    before(:each) do
      @schedule = ScheduleHelper::Graph.new
    end

    describe "Build graph" do

    end

    describe "Build slots" do
      before(:each) do
        @start = DateTime.new(2016, 01, 01, 8, 0, 0)
        @finish = DateTime.new(2016, 01, 01, 11, 0, 0)
      end

      it "When slots is in one day" do
        @schedule.send(:build_slots, @start, @finish, Time.parse("08:00"), Time.parse("11:00"), 1.hour)
        expect(@schedule.slots.count).to be(3)
        expect(@schedule.slots[0].id).to eq(DateTime.new(2016, 01, 01, 8, 0, 0))
        expect(@schedule.slots[1].id).to eq(DateTime.new(2016, 01, 01, 9, 0, 0))
        expect(@schedule.slots[2].id).to eq(DateTime.new(2016, 01, 01, 10, 0, 0))
      end
    end

    describe "Build edges" do
      before(:each) do
        @user1 = create(:user,username: "user1", email: "user1@mail.com")
        @user2 = create(:user,username: "user2", email: "user2@mail.com")


        @slot1 = GraphElements::Vertex.new(DateTime.new(2016, 01, 01, 8, 0, 0))
        @slot2 = GraphElements::Vertex.new(DateTime.new(2016, 01, 01, 9, 0, 0))
        @slot3 = GraphElements::Vertex.new(DateTime.new(2016, 01, 01, 10, 0, 0))
        @schedule.instance_variable_set :@slots, [@slot1, @slot2, @slot3]
        @schedule.instance_variable_set :@slots_size, 1.hour
        @schedule.instance_variable_set :@users, [@user1, @user2]
      end

      it "When users have empty slots" do
        @user1.schedule.create_event("title1", DateTime.new(2016, 01, 01, 8, 0, 0), 1.hour)
        @user2.schedule.create_event("title2", DateTime.new(2016, 01, 01, 10, 0, 0), 1.hour)

        @schedule.send(:build_edges, DateTime.new(2016, 01, 01, 8, 0, 0), DateTime.new(2016, 01, 01, 11, 0, 0))

        expect(@slot1.edges.count).to be(1)
        expect(@slot2.edges.count).to be(2)
        expect(@slot3.edges.count).to be(1)
      end

      it "When users have empty slots" do
        @user1.schedule.create_event("title1", DateTime.new(2016, 01, 01, 8, 0, 0), 3.hours)
        @user2.schedule.create_event("title2", DateTime.new(2016, 01, 01, 8, 0, 0), 3.hours)

        @schedule.send(:build_edges, DateTime.new(2016, 01, 01, 8, 0, 0), DateTime.new(2016, 01, 01, 11, 0, 0))

        expect(@slot1.edges).to be_empty
        expect(@slot2.edges).to be_empty
        expect(@slot3.edges).to be_empty
      end
    end

    describe "Slot empty" do
      before(:each) do
        @event = build(:event)
        @schedule.instance_variable_set :@slots_size, 1.hour
      end

      it "When slot match event" do
        slot = GraphElements::Vertex.new(DateTime.new(2016, 01, 01, 10, 0, 0))
        result = @schedule.send(:slot_empty?, slot, @event)
        expect(result).to be(false)
      end

      it "When slot not match event" do
        slot = GraphElements::Vertex.new(DateTime.new(2016, 01, 01, 8, 0, 0))
        result = @schedule.send(:slot_empty?, slot, @event)
        expect(result).to be(true)
      end
    end

    describe "Finish of day is ok" do
      it "When the finish day is smaller than max day" do
        start = DateTime.new
        finish = start + 1.day

        result = @schedule.send(:finish_day_ok?, start, finish)
        expect(result).to be(true)
      end
      
      it "When the finish day is equal max day" do
        start = DateTime.new
        finish = start + 1.month

        result = @schedule.send(:finish_day_ok?, start, finish)
        expect(result).to be(true)
      end

      it "When the finish day is bigger than max of day" do
        start = DateTime.new
        finish = start + 1.month + 1.hour

        result = @schedule.send(:finish_day_ok?, start, finish)
        expect(result).to be(false)
      end
    end
  end
end
