module SocialFramework
  class Schedule < ActiveRecord::Base
    belongs_to :user
    has_many :participant_events
    has_many :events, through: :participant_events

    def create_event title, start, finish, description = "", particular = false
      event = Event.create(title: title, start: start, finish: finish,
          description: description, particular: particular)

      ParticipantEvent.create(event: event, schedule: self, confirmed: true, role: "creator")
    end
  end
end
