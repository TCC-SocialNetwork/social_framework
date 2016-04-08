module SocialFramework
  class Event < ActiveRecord::Base
  	has_many :participant_events
  	has_many :schedules, through: :participant_events

  	def invite inviting, guest, relationship = "all"
  		participant_event = ParticipantEvent.find_by_event_id_and_schedule_id(self.id, inviting.schedule.id)

  		return if participant_event.nil?

  		if inviting.relationships(relationship).include?(guest) and participant_event.role != "participant"
      	ParticipantEvent.create(event: self, schedule: guest.schedule, confirmed: false, role: "participant")
      end
  	end
  end
end
