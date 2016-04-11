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
    # Returns ParticipantEvent updated or nil if maker has no permissions required
    def change_participant_role maker, participant, permission
      maker = ParticipantEvent.find_by_event_id_and_schedule_id(self.id, maker.schedule.id)
      participant = ParticipantEvent.find_by_event_id_and_schedule_id(self.id, participant.schedule.id)
      return false if maker.nil? or participant.nil?

      words = permission.to_s.split('_')
      if has_permission(permission, maker, participant, words.first)
        if permission == :make_creator
          maker.role = "admin"
          maker.save
        end

        role = (words.first == "remove" ? "participant" : words.last)
        participant.role = role if not words.first == "remove" or participant.role == words.last

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
      remover = ParticipantEvent.find_by_event_id_and_schedule_id(self.id, remover.schedule.id)
      participant = ParticipantEvent.find_by_event_id_and_schedule_id(self.id, participant.schedule.id)
      return if remover.nil? or participant.nil?

      permission = "remove_#{participant.role}".to_sym


      if has_permission(permission, remover, participant, "remove")
        participant.destroy
      end
    end

    private

    # Verify if exist permission to some action
    # ====== Params:
    # +permission+:: +Symbol+ permission to verify
    # +requester+:: +User+ responsible to make other user an administrator, should be current_user
    # +participant+:: +User+ to make administrator
    # +action+:: +String+ remove or make to remove or change role
    # Returns true if has permission or false if no
    def has_permission permission, requester, participant, action
      requester_permissions = SocialFramework.event_permissions[requester.role.to_sym]

      return (requester.confirmed and (participant.confirmed or action == "remove") and
                  requester_permissions.include? permission and participant.role != "creator")
    end
  end
end
