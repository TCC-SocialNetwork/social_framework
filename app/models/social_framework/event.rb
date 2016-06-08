module SocialFramework
  # Class that represents events that may have a schedule
  class Event < ActiveRecord::Base
  	has_many :participant_events
  	has_many :schedules, through: :participant_events
    belongs_to :route

    # Invite someone to an event
    # # ====== Params:
    # +inviting+:: +User+ responsible to invite other user, should be current_user
    # +guest+:: +User+ invited, must be in inviting relationships
    # +relationship+:: +String+ relationships types to find users, default is all to consider any relationship, can be an Array too with multiple relationships types
    # Returns nil if inviting has not :invite permission or isn't in event or the new ParticipantEvent created
  	def invite inviting, guest, relationship = SocialFramework.relationship_type_to_invite
  		participant_event = ParticipantEvent.find_by_event_id_and_schedule_id_and_confirmed(
        self.id, inviting.schedule.id, true)

  		return if participant_event.nil?

      invite_permission = SocialFramework.event_permissions[participant_event.role.to_sym].include? :invite
  		if inviting.relationships(relationship).include?(guest) and  invite_permission
      	ParticipantEvent.create(event: self, schedule: guest.schedule, confirmed: false, role: "participant")
      end
  	end

    # Make a event participant an administrator or inviter
    # ====== Params:
    # +maker+:: +User+ responsible to make other user an administrator, should be current_user
    # +participant+:: +User+ to make administrator
    # +action+:: +Symbol+ to verify
    # Returns ParticipantEvent updated or nil if maker has no actions required
    def change_participant_role maker, participant, action
      maker = ParticipantEvent.find_by_event_id_and_schedule_id(self.id, maker.schedule.id)
      participant = ParticipantEvent.find_by_event_id_and_schedule_id(self.id, participant.schedule.id)
      return false if maker.nil? or participant.nil?

      words = action.to_s.split('_')
      if execute_action?(action, maker, participant, words.first)
        if action == :make_creator
          maker.role = "admin"
          maker.save
        end

        role = (words.first == "remove" ? "participant" : words.last)
        participant.role = role if words.first == "make" or participant.role == words.last

        return participant.save
      end

      return false
    end

    # Remove participants of the event
    # ====== Params:
    # +remover+:: +User+ responsible to remove participant, should be current_user
    # +participant+:: +User+ to remove
    # Returns nil if has no permission or ParcipantEvent removed
    def remove_participant(remover, participant)
      return if remover.nil? or participant.nil?
      
      remover = ParticipantEvent.find_by_event_id_and_schedule_id(self.id, remover.schedule.id)
      participant_event = ParticipantEvent.find_by_event_id_and_schedule_id(
        self.id, participant.schedule.id)

      return if remover.nil? or participant_event.nil?

      permission = "remove_#{participant_event.role}".to_sym

      if execute_action?(permission, remover, participant_event, "remove")
        self.route.users.delete(participant) unless self.route.nil?
        participant_event.destroy
      end
    end

    # Add a route to this event
    # ====== Params:
    # +user+:: +User+ responsible to add the route to event
    # +route+:: +Route+ to add to event
    # Returns nil if inviting has not :add_route permission or isn't in event
    def add_route(user, route)
      participant_event = ParticipantEvent.find_by_event_id_and_schedule_id_and_confirmed(
        self.id, user.schedule.id, true)
      return if participant_event.nil?

      if has_permission?(:add_route, participant_event)
        self.route = route
        relation_users_route

        self.save
      end
    end

    protected

    # Verify if exist permission
    # ====== Params:
    # +permission+:: +Symbol+ permission to verify
    # +requester+:: +User+ responsible to make other user an administrator, should be current_user
    # Returns true if has permission or false if no
    def has_permission? permission, requester
      requester_permissions = SocialFramework.event_permissions[requester.role.to_sym]
      return (requester.confirmed and requester_permissions.include? permission)
    end

    # Verify if can be execute some action
    # ====== Params:
    # +permission+:: +Symbol+ permission to verify
    # +requester+:: +User+ responsible to make other user an administrator, should be current_user
    # +participant+:: +ParticipantEvent+ to make administrator
    # +action+:: +String+ remove or make to remove or change role
    # Returns true if has permission or false if no
    def execute_action? permission, requester, participant, action
      permission = has_permission?(permission, requester)
      return (permission and (participant.confirmed or action == "remove") and
        participant.role != "creator")
    end

    # Add all users in this event to route
    # Returns route with all users added
    def relation_users_route
      return if self.route.nil?

      users.each do |user|
        self.route.users << user unless self.route.users.include? user
      end
    end

    # Get all users confirmed in event
    # Confirmed event users
    def users
      result = Array.new
      participant_events.each do |participant|
        result << participant.schedule.user if participant.confirmed
      end

      return result
    end
  end
end
