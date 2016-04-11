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
      return if finish.nil? or not check_disponibility(start, finish)

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
    # +finish+:: +DateTime+ event finish, if nil is start.end_of_day
    # Returns true if exist disponibility or false if no
    def check_disponibility(start, finish = start.end_of_day)
      existent_events = SocialFramework::Event.joins(:participant_events).where(
        "social_framework_participant_events.schedule_id = ? AND " +
        "social_framework_participant_events.confirmed = ? AND " + 
        "social_framework_events.start < ? AND " +
        "social_framework_events.finish > ?", self.id, true, finish, start)

      return existent_events.empty?
    end

    # Confirm an event to schedule
    # ====== Params:
    # +event+:: +Event+ to confirm
    # Returns false if no exist a invitation or has no disponibility or true if could confirm event
    def confirm_event(event)
      participant_event = ParticipantEvent.find_by_event_id_and_schedule_id(event.id, self.id)

      return false if participant_event.nil? or not check_disponibility(event.start, event.finish)

      participant_event.confirmed = true
      participant_event.save
    end

    # Exit of an event
    # ====== Params:
    # +event+:: +Event+ to exit
    # Returns ParticipantEvent destroyed or nil if user is creator
    def exit_event(event)
      participant_event = ParticipantEvent.find_by_event_id_and_schedule_id(event.id, self.id)
      participant_event.destroy if participant_event.role != "creator"
    end

    # Remove an event created by self.user
    # ====== Params:
    # +event+:: +Event+ to remove
    # Returns Event destroyed or nil if user is not creator
    def remove_event(event)
      participant_event = ParticipantEvent.find_by_event_id_and_schedule_id(event.id, self.id)
      event.destroy if participant_event.role == "creator"
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
