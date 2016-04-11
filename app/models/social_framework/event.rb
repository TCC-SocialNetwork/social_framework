module SocialFramework
  class Event < ActiveRecord::Base
  	has_many :participant_events
  	has_many :schedules, through: :participant_events

    # Invite someone to an event
    # # ====== Params:
    # +inviting+:: +User+ responsible to invite other user, should be current_user
    # +guest+:: +User+ invited, must be in inviting relationships
    # +relationship+:: +String+ relationships types to find users, default is all to consider any relationship, can be an Array too with multiple relationships types
    # Returns nil if inviting has not :invite permission or isn't in event or the new ParticipantEvent created
  	def invite inviting, guest, relationship = SocialFramework.relationship_type_to_invite
  		participant_event = ParticipantEvent.find_by_event_id_and_schedule_id(self.id, inviting.schedule.id)

  		return if participant_event.nil? or not participant_event.confirmed

      invite_permission = SocialFramework.event_permissions[participant_event.role.to_sym].include? :invite
  		if inviting.relationships(relationship).include?(guest) and  invite_permission
      	ParticipantEvent.create(event: self, schedule: guest.schedule, confirmed: false, role: "participant")
      end
  	end

    # Make a event participant an administrator or inviter
    # ====== Params:
    # +maker+:: +User+ responsible to make other user an administrator, should be current_user
    # +participant+:: +User+ to make administrator
    # +permission+:: +Symbol+ to verify
    # +role+:: +String+ new role to participant
    # Returns ParticipantEvent updated or nil if maker has no permissions required
    def change_participant_role maker, participant, permission, role
      maker = ParticipantEvent.find_by_event_id_and_schedule_id(self.id, maker.schedule.id)
      participant = ParticipantEvent.find_by_event_id_and_schedule_id(self.id, participant.schedule.id)

      if has_permission(permission, maker, participant)
        if role == "creator"
          maker.role = "admin"
          maker.save
        end

        participant.role = role
        return participant.save
      end

      return false
    end

    private

    # Verify if exist permission to some action
    # ====== Params:
    # +permission+:: +Symbol+ permission to verify
    # +maker+:: +User+ responsible to make other user an administrator, should be current_user
    # +participant+:: +User+ to make administrator
    # Returns true if has permission or false if no
    def has_permission permission, maker, participant
      maker_permissions = SocialFramework.event_permissions[maker.role.to_sym]

      return (maker.confirmed and participant.confirmed and
                  maker_permissions.include? permission and participant.role != "creator")
    end
  end
end
