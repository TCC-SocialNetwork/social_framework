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
        result = @event.change_participant_role(@user1, @user2, :make_admin)

        expect(result).to be(true)
        participant = ParticipantEvent.find_by_event_id_and_schedule_id(@event.id, @user2.schedule.id)
        expect(participant.role).to eq("admin")

        result = @event.invite @user2, @user3

        expect(result).not_to be_nil
        expect(@user3.schedule.events.count).to be(1)
        expect(result.confirmed).to be(false)
        expect(result.role).to eq("participant")
      end
    end

    describe "Change participants roles" do
      it "When creator try make administrator" do
        @user1.create_relationship @user2, "r1", true, true
        @user2.create_relationship @user3, "r1", true, true

        @event.invite @user1, @user2
        @user2.schedule.confirm_event(@event)
        result = @event.change_participant_role(@user1, @user2, :make_admin)

        expect(result).to be(true)
        participant = ParticipantEvent.find_by_event_id_and_schedule_id(@event.id, @user2.schedule.id)
        expect(participant.role).to eq("admin")
      end

      it "When an administrator try make creator as administrator" do
        @user1.create_relationship @user2, "r1", true, true
        @user2.create_relationship @user3, "r1", true, true

        @event.invite @user1, @user2
        @user2.schedule.confirm_event(@event)
        @event.change_participant_role(@user1, @user2, :make_admin)

        result = @event.change_participant_role(@user2, @user1, :make_admin)
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
        
        result = @event.change_participant_role(@user2, @user3, :make_admin)
        expect(result).to be(false)

        participant = ParticipantEvent.find_by_event_id_and_schedule_id(@event.id, @user3.schedule.id)
        expect(participant.role).to eq("participant")
      end

      it "When creator try make inviter" do
        @user1.create_relationship @user2, "r1", true, true
        @user2.create_relationship @user3, "r1", true, true

        @event.invite @user1, @user2
        @user2.schedule.confirm_event(@event)
        result = @event.change_participant_role(@user1, @user2, :make_inviter)

        expect(result).to be(true)
        participant = ParticipantEvent.find_by_event_id_and_schedule_id(@event.id, @user2.schedule.id)
        expect(participant.role).to eq("inviter")
      end

      it "When an administrator try make inviter" do
        @user1.create_relationship @user2, "r1", true, true
        @user2.create_relationship @user3, "r1", true, true

        @event.invite @user1, @user2
        @user2.schedule.confirm_event(@event)
        @event.change_participant_role(@user1, @user2, :make_admin)

        @event.invite @user2, @user3
        @user3.schedule.confirm_event(@event)
        result = @event.change_participant_role(@user2, @user3, :make_inviter)

        expect(result).to be(true)
        participant = ParticipantEvent.find_by_event_id_and_schedule_id(@event.id, @user3.schedule.id)
        expect(participant.role).to eq("inviter")
      end

      it "When an administrator try make inviter" do
        @user1.create_relationship @user2, "r1", true, true
        @user1.create_relationship @user3, "r1", true, true

        @event.invite @user1, @user2
        @event.invite @user1, @user3
        @user2.schedule.confirm_event(@event)
        @user3.schedule.confirm_event(@event)


        result = @event.change_participant_role(@user2, @user3, :make_inviter)

        expect(result).to be(false)
        participant = ParticipantEvent.find_by_event_id_and_schedule_id(@event.id, @user3.schedule.id)
        expect(participant.role).to eq("participant")
      end

      it "When a simple participant try make inviter" do
        @user1.create_relationship @user2, "r1", true, true
        @user1.create_relationship @user3, "r1", true, true

        @event.invite @user1, @user2
        @event.invite @user1, @user3
        @user2.schedule.confirm_event(@event)
        @user3.schedule.confirm_event(@event)
        
        result = @event.change_participant_role(@user2, @user3, :make_inviter)
        expect(result).to be(false)

        participant = ParticipantEvent.find_by_event_id_and_schedule_id(@event.id, @user3.schedule.id)
        expect(participant.role).to eq("participant")
      end

      it "When a inter try make inviter" do
        @user1.create_relationship @user2, "r1", true, true
        @user1.create_relationship @user3, "r1", true, true

        @event.invite @user1, @user2
        @event.invite @user1, @user3
        @user2.schedule.confirm_event(@event)
        @user3.schedule.confirm_event(@event)
        
        @event.change_participant_role(@user1, @user2, :make_inviter)

        result = @event.change_participant_role(@user2, @user3, :make_inviter)
        
        expect(result).to be(false)

        participant = ParticipantEvent.find_by_event_id_and_schedule_id(@event.id, @user3.schedule.id)
        expect(participant.role).to eq("participant")
      end

      it "When creator try make creator" do
        @user1.create_relationship @user2, "r1", true, true
        @user2.create_relationship @user3, "r1", true, true

        @event.invite @user1, @user2
        @user2.schedule.confirm_event(@event)
        result = @event.change_participant_role(@user1, @user2, :make_creator)

        expect(result).to be(true)
        
        participant = ParticipantEvent.find_by_event_id_and_schedule_id(@event.id, @user2.schedule.id)
        expect(participant.role).to eq("creator")

        participant = ParticipantEvent.find_by_event_id_and_schedule_id(@event.id, @user1.schedule.id)
        expect(participant.role).to eq("admin")
      end

      it "When not creator participant try make creator" do
        @user1.create_relationship @user2, "r1", true, true
        @user2.create_relationship @user3, "r1", true, true

        @event.invite @user1, @user2
        @user2.schedule.confirm_event(@event)
        @event.change_participant_role(@user1, @user2, :make_admin)

        result = @event.change_participant_role(@user2, @user1, :make_creator)
        expect(result).to be(false)
        
        participant = ParticipantEvent.find_by_event_id_and_schedule_id(@event.id, @user2.schedule.id)
        expect(participant.role).to eq("admin")

        participant = ParticipantEvent.find_by_event_id_and_schedule_id(@event.id, @user1.schedule.id)
        expect(participant.role).to eq("creator")
      end

      it "When creator try remove administrator role" do
        @user1.create_relationship @user2, "r1", true, true
        @user2.create_relationship @user3, "r1", true, true

        @event.invite @user1, @user2
        @user2.schedule.confirm_event(@event)
        @event.change_participant_role(@user1, @user2, :make_admin)

        result = @event.change_participant_role(@user1, @user2, :remove_admin)

        expect(result).to be(true)
        participant = ParticipantEvent.find_by_event_id_and_schedule_id(@event.id, @user2.schedule.id)
        expect(participant.role).to eq("participant")
      end

      it "When try remove invalid role" do
        @user1.create_relationship @user2, "r1", true, true
        @user2.create_relationship @user3, "r1", true, true

        @event.invite @user1, @user2
        @user2.schedule.confirm_event(@event)
        @event.change_participant_role(@user1, @user2, :make_admin)

        result = @event.change_participant_role(@user2, @user1, :remove_admin)

        expect(result).to be(false)
        participant = ParticipantEvent.find_by_event_id_and_schedule_id(@event.id, @user1.schedule.id)
        expect(participant.role).to eq("creator")
      end

      it "When try remove creator role" do
        @user1.create_relationship @user2, "r1", true, true
        @user2.create_relationship @user3, "r1", true, true

        @event.invite @user1, @user2
        @user2.schedule.confirm_event(@event)
        @event.change_participant_role(@user1, @user2, :make_admin)

        result = @event.change_participant_role(@user2, @user1, :remove_creator)

        expect(result).to be(false)
        participant = ParticipantEvent.find_by_event_id_and_schedule_id(@event.id, @user1.schedule.id)
        expect(participant.role).to eq("creator")
      end

      it "When pass invalid params" do
        @user1.create_relationship @user2, "r1", true, true
        @event.invite @user1, @user2
        @user2.schedule.confirm_event(@event)
        result = @event.change_participant_role(@user1, @user3, :make_admin)

        expect(result).to be(false)
      end
    end

    describe "Remove participant" do
      it "When try remove a simple participant" do
        @user1.create_relationship @user2, "r1", true, true

        @event.invite @user1, @user2

        @event.remove_participant(@user1, @user2)
        expect(@event.participant_events.count).to be(1)
      end

      it "When try remove an administrator and inviter" do
        @user1.create_relationship @user2, "r1", true, true
        @user1.create_relationship @user3, "r1", true, true

        @event.invite @user1, @user2
        @event.invite @user1, @user3
        @user2.schedule.confirm_event(@event)
        @user3.schedule.confirm_event(@event)
        
        @event.change_participant_role(@user1, @user2, :make_admin)
        @event.change_participant_role(@user1, @user3, :make_inviter)

        @event.remove_participant(@user1, @user2)
        expect(@event.participant_events.count).to be(2)
        
        @event.remove_participant(@user1, @user3)
        expect(@event.participant_events.count).to be(1)
      end

      it "When try remove without permission" do
        @user1.create_relationship @user2, "r1", true, true

        @event.invite @user1, @user2
        @user2.schedule.confirm_event(@event)

        @event.remove_participant(@user2, @user1)
        expect(@event.participant_events.count).to be(2)
      end

      it "When pass invalid params" do
        @user1.create_relationship @user2, "r1", true, true
        @event.invite @user1, @user2
        @user2.schedule.confirm_event(@event)
        result = @event.remove_participant(@user1, @user3)

        expect(result).to be_nil
      end
    end

    describe "Verify permissions" do
      before(:each) do
        @participant = ParticipantEvent.find 1
      end

      it "When user has the permission required" do
        result = @event.send(:has_permission?, :make_admin, @participant)
        expect(result).to be(true)
      end

      it "When user hasn't the permission required" do
        result = @event.send(:has_permission?, :invalid, @participant)
        expect(result).to be(false)

      end      
    end

    describe "Execute action" do
      before(:each) do
        @user1.create_relationship @user2, "r1", true, true
        @user1.create_relationship @user3, "r1", true, true
        
        @event.invite @user1, @user2
        @event.invite @user1, @user3
        
        @user2.schedule.confirm_event(@event)

        @participant1 = ParticipantEvent.find 1
        @participant2 = ParticipantEvent.find 2
        @participant3 = ParticipantEvent.find 3
      end

      it "When requester hasn't the permission required" do
        result = @event.send(:execute_action?, :make_inviter,
          @participant2, @participant3, "inviter")
        expect(result).to be(false)
      end

      it "When participant is the event creator" do
        result = @event.send(:execute_action?, :make_admin,
          @participant2, @participant1, "admin")
        expect(result).to be(false)
      end

      it "When participant didn't confirmed the event" do
        result = @event.send(:execute_action?, :make_admin,
          @participant1, @participant3, "admin")
        expect(result).to be(false)
      end

      it "When participant didn't confirmed the event but action is remove" do
        result = @event.send(:execute_action?, :make_admin,
          @participant1, @participant3, "remove")
        expect(result).to be(true)
      end

      it "When everything is ok" do
        result = @event.send(:execute_action?, :make_admin,
          @participant1, @participant2, "admin")
        expect(result).to be(true)
      end
    end

    describe "Relation users and route" do
      before(:each) do
        @user1.create_relationship @user2, "r1", true, true
        @user1.create_relationship @user3, "r1", true, true

        locations = [{latitude: -15.792740000000002, longitude: -47.876360000000005},
                  {latitude: -15.792520000000001, longitude: -47.876900000000006}]
        @route = @user1.add_route("route", 63, locations)
      end

      it "When event hasn't a route" do
        result = @event.send(:relation_users_route)
        expect(result).to be_nil
      end

      it "When user in event already have the route" do
        @event.route = @route

        expect(@event.route.users.count).to be(1)
        
        result = @event.send(:relation_users_route)
        expect(result).not_to be_nil

        expect(@event.route.users.count).to be(1)
      end

      it "When users in event aren't confirmed" do
        @event.invite @user1, @user2
        @event.invite @user1, @user3
        @event.route = @route

        expect(@event.route.users.count).to be(1)
        
        result = @event.send(:relation_users_route)
        expect(result).not_to be_nil

        expect(@event.route.users.count).to be(1)
      end

      it "When users in event are confirmed" do
        @event.invite @user1, @user2
        @event.invite @user1, @user3
        @user2.schedule.confirm_event(@event)
        @user3.schedule.confirm_event(@event)

        @event.route = @route

        expect(@event.route.users.count).to be(1)
        
        result = @event.send(:relation_users_route)
        expect(result).not_to be_nil

        expect(@event.route.users.count).to be(3)
      end
    end

    describe "Get users confirmed" do
      before(:each) do
        @user1.create_relationship @user2, "r1", true, true
        @user1.create_relationship @user3, "r1", true, true

        @event.invite @user1, @user2
        @event.invite @user1, @user3
      end

      it "When exist users not confirmed in event" do
        result = @event.send(:users)
        expect(result.count).to be(1)
      end

      it "When not exist users not confirmed in event" do
        @user2.schedule.confirm_event(@event)
        @user3.schedule.confirm_event(@event)

        result = @event.send(:users)
        expect(result.count).to be(3)
      end
    end

    describe "Add route" do
      before(:each) do
        @user1.create_relationship @user2, "r1", true, true
        @user1.create_relationship @user3, "r1", true, true

        locations = [{latitude: -15.792740000000002, longitude: -47.876360000000005},
                  {latitude: -15.792520000000001, longitude: -47.876900000000006}]
        @route = @user1.add_route("route", 63, locations)

        @event.invite @user1, @user2
        @event.invite @user1, @user3
      end

      it "When users in event already have the route" do
        expect(@event.route).to be_nil
        expect(@route.users.count).to be(1)

        @event.add_route(@user1, @route)

        expect(@event.route).to eq(@route)
        expect(@route.users.count).to be(1)
      end

      it "When users in event haven't the route" do
        expect(@event.route).to be_nil
        expect(@route.users.count).to be(1)

        @user2.schedule.confirm_event(@event)
        @user3.schedule.confirm_event(@event)

        @event.add_route(@user1, @route)

        expect(@event.route).to eq(@route)
        expect(@route.users.count).to be(3)
      end

      it "When participant_event isn't confirmed" do
        expect(@event.route).to be_nil
        expect(@route.users.count).to be(1)

        result = @event.add_route(@user2, @route)

        expect(result).to be_nil
        expect(@event.route).to be_nil
        expect(@route.users.count).to be(1)
      end

      it "When participant_event hasn't permission" do
        expect(@event.route).to be_nil
        expect(@route.users.count).to be(1)

        @user2.schedule.confirm_event(@event)
        @user3.schedule.confirm_event(@event)
        @event.add_route(@user2, @route)

        expect(@event.route).to be_nil
        expect(@route.users.count).to be(1)
      end      
    end
  end
end