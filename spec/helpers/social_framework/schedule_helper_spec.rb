require 'rails_helper'


module SocialFramework
  RSpec.describe ScheduleHelper, type: :helper do
    before(:each) do
      @schedule = ScheduleHelper::Graph.new
    end

    describe "Build graph" do
      before(:each) do
        @user1 = create(:user,username: "user1", email: "user1@mail.com")
        @user2 = create(:user,username: "user2", email: "user2@mail.com")
        @user3 = create(:user,username: "user3", email: "user3@mail.com")
        @user4 = create(:user,username: "user4", email: "user4@mail.com")
      end

      it "When the events is in one day" do
        start = DateTime.new(2016, 01, 01, 8, 0, 0)
        @user1.schedule.create_event "title2", start, 1.hour

        start = DateTime.new(2016, 01, 01, 8, 0, 0)
        @user2.schedule.create_event "title2", start, 2.hours

        start = DateTime.new(2016, 01, 01, 9, 0, 0)
        @user1.schedule.create_event "title3", start, 1.hour

        start = DateTime.new(2016, 01, 01, 10, 0, 0)
        @user1.schedule.create_event "title3", start, 1.hour

        start = DateTime.new(2016, 01, 01, 12, 0, 0)
        @user1.schedule.create_event "title4", start, 1.hour

        @schedule.build([@user1, @user2], Date.parse("01/01/2016"), Date.parse("01/01/2016"),
          Time.parse("08:00"), Time.parse("14:00"))

        expect(@schedule.slots.count).to be(6)
        expect(@schedule.slots[0].edges.count).to be(2)
        expect(@schedule.slots[1].edges.count).to be(2)
        expect(@schedule.slots[2].edges.count).to be(1)
        expect(@schedule.slots[3].edges.count).to be(1)
        expect(@schedule.slots[4].edges).to be_empty
        expect(@schedule.slots[5].edges).to be_empty
      end

      it "When the events is in two days" do
        start = DateTime.new(2016, 01, 01, 23, 0, 0)
        @user1.schedule.create_event "title2", start, 2.hours

        start = DateTime.new(2016, 01, 01, 22, 0, 0)
        @user2.schedule.create_event "title3", start, 4.hours

        @schedule.build([@user1, @user2], Date.parse("01/01/2016"), Date.parse("02/01/2016"),
          Time.parse("21:00"), Time.parse("03:00"))

        expect(@schedule.slots.count).to be(6)
        expect(@schedule.slots[0].edges.count).to be(2)
        expect(@schedule.slots[1].edges.count).to be(2)
        expect(@schedule.slots[2].edges.count).to be(1)
        expect(@schedule.slots[3].edges.count).to be(1)
        expect(@schedule.slots[4].edges).to be_empty
        expect(@schedule.slots[5].edges).to be_empty
      end

      it "When the events multiple days duration" do
        start = DateTime.new(2016, 01, 01, 10, 0, 0)
        @user1.schedule.create_event "title2", start, (1.day + 13.hours)

        start = DateTime.new(2016, 01, 01, 9, 0, 0)
        @user2.schedule.create_event "title3", start, (1.day + 2.hours)

        @schedule.build([@user1, @user2], Date.parse("01/01/2016"), Date.parse("02/01/2016"))

        expect(@schedule.slots.count).to be(48)

        (0..9).each do |i|
          expect(@schedule.slots[i].edges.count).to be(2)
        end

        (10..22).each do |i|
          expect(@schedule.slots[i].edges.count).to be(1)
        end

        (23..47).each do |i|
          expect(@schedule.slots[i].edges).to be_empty
        end
      end

      it "When the users have weight" do
        @user1.schedule.create_event("title1", DateTime.new(2016, 01, 01, 8, 0, 0), 1.hours)
        @user2.schedule.create_event("title2", DateTime.new(2016, 01, 01, 10, 0, 0), 1.hours)

        hash = {}
        hash[@user1] = 3
        hash[@user2] = 8
        @schedule.build(hash, Date.parse("01/01/2016"), Date.parse("01/01/2016"),
          Time.parse("08:00"), Time.parse("11:00"))

        expect(@schedule.slots.count).to be(3)
        expect(@schedule.slots[0].edges.count).to be(2)
        expect(@schedule.slots[0].attributes[:gained_weight]).to be(11)
        expect(@schedule.slots[1].edges.count).to be(1)
        expect(@schedule.slots[1].attributes[:gained_weight]).to be(8)
        expect(@schedule.slots[2].edges.count).to be(1)
        expect(@schedule.slots[2].attributes[:gained_weight]).to be(3)
      end

      it "When exist fixed users" do
        start = DateTime.new(2016, 01, 01, 8, 0, 0)
        @user1.schedule.create_event "title1", start, 2.hours

        hash = Hash[[@user1, @user2].map {|k| [k, nil]}]
        hash[@user1] = :fixed

        @schedule.build(hash, Date.parse("01/01/2016"), Date.parse("01/01/2016"),
          Time.parse("08:00"), Time.parse("11:00"))

        fixed_users = @schedule.instance_variable_get :@fixed_users
        users = @schedule.instance_variable_get :@users

        expect(fixed_users.count).to be(1)
        expect(users.count).to be(1)
        expect(@schedule.slots.count).to be(1)
        expect(@schedule.slots.first.edges.count).to be(2)
      end

      it "When is not possible group the fixed users" do
        start = DateTime.new(2016, 01, 01, 8, 0, 0)
        @user1.schedule.create_event "title1", start, 2.hours

        start = DateTime.new(2016, 01, 01, 10, 0, 0)
        @user2.schedule.create_event "title1", start, 1.hours

        hash = Hash[[@user1, @user2].map {|k| [k, :fixed]}]
        @schedule.build(hash, Date.parse("01/01/2016"), Date.parse("01/01/2016"),
          Time.parse("08:00"), Time.parse("11:00"))

        fixed_users = @schedule.instance_variable_get :@fixed_users
        users = @schedule.instance_variable_get :@users

        expect(fixed_users.count).to be(2)
        expect(users).to be_empty
        expect(@schedule.slots).to be_empty
      end

      it "When exist multiple users fixed" do
        start = DateTime.new(2016, 01, 01, 8, 0, 0)
        @user1.schedule.create_event "title1", start, 1.hours

        start = DateTime.new(2016, 01, 01, 11, 0, 0)
        @user2.schedule.create_event "title1", start, 1.hours

        start = DateTime.new(2016, 01, 01, 9, 0, 0)
        @user3.schedule.create_event "title1", start, 1.hours

        start = DateTime.new(2016, 01, 01, 10, 0, 0)
        @user4.schedule.create_event "title1", start, 1.hours

        hash = Hash[[@user1, @user2].map {|k| [k, :fixed]}]
        hash[@user3] = 5
        hash[@user4] = 8

        @schedule.build(hash, Date.parse("01/01/2016"), Date.parse("01/01/2016"),
          Time.parse("08:00"), Time.parse("12:00"))

        fixed_users = @schedule.instance_variable_get :@fixed_users
        users = @schedule.instance_variable_get :@users

        expect(fixed_users.count).to be(2)
        expect(users.count).to be(2)
        expect(@schedule.slots.count).to be(2)
        expect(@schedule.slots.first.attributes[:gained_weight]).to be(8)
        expect(@schedule.slots.last.attributes[:gained_weight]).to be(5)
      end

      it "When users weight is bigger than fixed users" do
        start = DateTime.new(2016, 01, 01, 8, 0, 0)
        @user1.schedule.create_event "title1", start, 3.hours

        start = DateTime.new(2016, 01, 01, 11, 0, 0)
        @user2.schedule.create_event "title1", start, 1.hours

        start = DateTime.new(2016, 01, 01, 11, 0, 0)
        @user3.schedule.create_event "title1", start, 1.hours

        hash = Hash[[@user2, @user3].map {|k| [k, nil]}]
        hash[@user1] = :fixed

        @schedule.build(hash, Date.parse("01/01/2016"), Date.parse("01/01/2016"),
          Time.parse("08:00"), Time.parse("12:00"))

        fixed_users = @schedule.instance_variable_get :@fixed_users
        users = @schedule.instance_variable_get :@users

        expect(fixed_users.count).to be(1)
        expect(users.count).to be(2)
        expect(@schedule.slots.count).to be(1)
        expect(@schedule.slots.first.attributes[:gained_weight]).to be(0)
      end
    end

    describe "Build slots" do
      before(:each) do
        @start = DateTime.new(2016, 01, 01, 8, 0, 0)
        @finish = DateTime.new(2016, 01, 01, 11, 0, 0)
      end

      it "When slots is in one day" do
        @schedule.instance_variable_set :@slots_size, 1.hour
        @schedule.send(:build_slots, @start, @finish, Time.parse("08:00"), Time.parse("11:00"))
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

        @slot1 = GraphElements::Vertex.new(DateTime.new(2016, 01, 01, 8, 0, 0), {gained_weight: 0})
        @slot2 = GraphElements::Vertex.new(DateTime.new(2016, 01, 01, 9, 0, 0), {gained_weight: 0})
        @slot3 = GraphElements::Vertex.new(DateTime.new(2016, 01, 01, 10, 0, 0), {gained_weight: 0})
        @schedule.instance_variable_set :@slots, [@slot1, @slot2, @slot3]
        @schedule.instance_variable_set :@slots_size, 1.hour
      end

      it "When users have empty slots" do
        @user1.schedule.create_event("title1", DateTime.new(2016, 01, 01, 8, 0, 0), 1.hour)
        @user2.schedule.create_event("title2", DateTime.new(2016, 01, 01, 10, 0, 0), 1.hour)
        @schedule.send(:build_users, [@user1, @user2])
        users = @schedule.instance_variable_get :@users

        @schedule.send(:build_edges, users, DateTime.new(2016, 01, 01, 8, 0, 0), DateTime.new(2016, 01, 01, 11, 0, 0))

        expect(@slot1.edges.count).to be(1)
        expect(@slot2.edges.count).to be(2)
        expect(@slot3.edges.count).to be(1)
      end

      it "When users have empty slots" do
        @user1.schedule.create_event("title1", DateTime.new(2016, 01, 01, 8, 0, 0), 3.hours)
        @user2.schedule.create_event("title2", DateTime.new(2016, 01, 01, 8, 0, 0), 3.hours)
        @schedule.send(:build_users, [@user1, @user2])
        users = @schedule.instance_variable_get :@users

        @schedule.send(:build_edges, users, DateTime.new(2016, 01, 01, 8, 0, 0), DateTime.new(2016, 01, 01, 11, 0, 0))

        expect(@slot1.edges).to be_empty
        expect(@slot2.edges).to be_empty
        expect(@slot3.edges).to be_empty
      end

      it "When the users have weight" do
        @user1.schedule.create_event("title1", DateTime.new(2016, 01, 01, 8, 0, 0), 1.hour)
        @user2.schedule.create_event("title2", DateTime.new(2016, 01, 01, 10, 0, 0), 1.hour)
        
        hash = {}
        hash[@user1] = 5
        hash[@user2] = 7

        @schedule.send(:build_users, hash)
        users = @schedule.instance_variable_get :@users

        @schedule.send(:build_edges, users, DateTime.new(2016, 01, 01, 8, 0, 0), DateTime.new(2016, 01, 01, 11, 0, 0))

        expect(@slot1.attributes[:gained_weight]).to be(7)
        expect(@slot2.attributes[:gained_weight]).to be(12)
        expect(@slot3.attributes[:gained_weight]).to be(5)
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

    describe "Calculate slots quantity" do
      it "When start hour is smaller than finish hour" do
        @schedule.instance_variable_set :@slots_size, 1.hour
        result = @schedule.send(:get_slots_quantity, Time.parse("03:00"), Time.parse("21:00"))
        expect(result).to be(18)
      end

      it "When start hour is bigger than finish hour" do
        @schedule.instance_variable_set :@slots_size, 1.hour
        result = @schedule.send(:get_slots_quantity, Time.parse("21:00"), Time.parse("03:00"))
        expect(result).to be(6)
      end
    end

    describe "Build users" do
      before(:each) do
        @user1 = create(:user,username: "user1", email: "user1@mail.com")
        @user2 = create(:user,username: "user2", email: "user2@mail.com")
      end

      it "When is an array" do
        @schedule.send(:build_users, [@user1, @user2])
        users = @schedule.instance_variable_get :@users
        expect(users.count).to be(2)
        expect(users.first.attributes[:weight]).to be(10)
        expect(users.last.attributes[:weight]).to be(10)
      end

      it "When is a hash" do
        hash = {}
        hash[@user1] = 5
        hash[@user2] = 9
        @schedule.send(:build_users, hash)
        users = @schedule.instance_variable_get :@users
        expect(users.count).to be(2)
        expect(users.first.attributes[:weight]).to be(5)
        expect(users.last.attributes[:weight]).to be(9)
      end

      it "When exist fixed users" do
        hash = {}
        hash[@user1] = 5
        hash[@user2] = :fixed
        @schedule.send(:build_users, hash)

        users = @schedule.instance_variable_get :@users
        fixed_users = @schedule.instance_variable_get :@fixed_users

        expect(users.count).to be(1)
        expect(users.first.attributes[:weight]).to be(5)

        expect(fixed_users.count).to be(1)
      end
    end
  end
end
