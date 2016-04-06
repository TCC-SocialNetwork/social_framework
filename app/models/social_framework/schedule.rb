module SocialFramework
  class Schedule < ActiveRecord::Base
    belongs_to :user
    has_many :participant_events
    has_many :events, through: :participant_events

    # Create an event to user this schedule
    # ====== Params:
    # +title+:: +String+ event title
    # +start+:: +DateTime+ date and hour to start event
    # +duration+:: +ActiveSupport::Duration+ of the event, if nil is used until end of start day
    # +description+:: +String+ event description, default is ""
    # +particular+:: +Boolean+ set event as private or not, default is false
    # Returns event created or nil in error case
    def create_event title, start, duration = nil, description = "", particular = false
      if duration.nil?
        finish = start.end_of_day
      else
        return unless duration.class == ActiveSupport::Duration

        finish = start + duration
      end

      event = Event.create(title: title, start: start, finish: finish,
          description: description, particular: particular)

      unless event.nil?
        ParticipantEvent.create(event: event, schedule: self, confirmed: true, role: "creator")
      end

      return event
    end
  end
end
