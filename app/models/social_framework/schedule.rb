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
      finish = set_finish_date(start, duration)
      return if finish.nil?

      event = Event.create(title: title, start: start, finish: finish,
          description: description, particular: particular)

      unless event.nil?
        ParticipantEvent.create(event: event, schedule: self, confirmed: true, role: "creator")
      end

      return event
    end

    # Check disponibility in specific time interval
    # ====== Params:
    # +start+:: +DateTime+ event start
    # +duration+:: +ActiveSupport::Duration+ of the event, if nil is used until end of start day
    # Returns true if exist disponibility or false if no
    def check_disponibility(start, duration = nil)
      finish = set_finish_date(start, duration)

      existent_events = SocialFramework::Event.joins(:participant_events).where("social_framework_participant_events.confirmed = ? AND social_framework_events.start < ? AND social_framework_events.finish > ?", true, finish, start)
      return existent_events.empty?
    end

    private

    # Set finish date from duration
    # ====== Params:
    # +start+:: +DateTime+ event start
    # +duration+:: +ActiveSupport::Duration+ of the event, if nil is used until end of start day
    # Returns finish date
    def set_finish_date(start, duration)
      if duration.nil?
        return start.end_of_day
      else
        return if duration.class != ActiveSupport::Duration or duration < 0 or duration == 0

        return start + duration
      end
    end
  end
end
