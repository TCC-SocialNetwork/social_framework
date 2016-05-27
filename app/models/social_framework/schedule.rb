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
    def create_event(title, start, duration = nil, description = "", particular = false)
      finish = set_finish_date(start, duration)
      return if finish.nil? or not events_in_period(start, finish).empty?

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
    def events_in_period(start, finish = start.end_of_day)
      events = SocialFramework::Event.joins(:participant_events).where(
        "social_framework_participant_events.schedule_id = ? AND " +
        "social_framework_participant_events.confirmed = ? AND " + 
        "social_framework_events.start < ? AND " +
        "social_framework_events.finish > ?", self.id, true, finish, start).order(start: :asc)

      return events
    end

    # Confirm an event to schedule
    # ====== Params:
    # +event+:: +Event+ to confirm
    # Returns false if no exist a invitation or has no disponibility or true if could confirm event
    def confirm_event(event)
      participant_event = get_participant_event(event)
      return false if participant_event.nil? or not events_in_period(event.start, event.finish).empty?

      relation_user_route(event)
      participant_event.confirmed = true
      participant_event.save
    end

    # Exit of an event
    # ====== Params:
    # +event+:: +Event+ to exit
    # Returns ParticipantEvent destroyed or nil if user is creator
    def exit_event(event)
      self.user.routes.delete(event.route) unless event.route.nil?

      participant_event = get_participant_event(event)
      participant_event.destroy if not participant_event.nil? and participant_event.role != "creator"
    end

    # Remove an event created by self.user
    # ====== Params:
    # +event+:: +Event+ to remove
    # Returns Event destroyed or nil if user is not creator
    def remove_event(event)
      event.route.destroy unless event.route.nil?
      participant_event = get_participant_event(event)
      event.destroy if not participant_event.nil? and participant_event.role == "creator"
    end

    # Enter in an public event
    # ====== Params:
    # +event+:: +Event+ to enter
    # Returns ParticipantEvent created or nil if that event is particular or already exist events in that period
    def enter_in_event(event)
      return if event.nil? or event.particular or not events_in_period(event.start, event.finish).empty?

      if get_participant_event(event).nil?
        relation_user_route(event)
        ParticipantEvent.create(event: event, schedule: self, confirmed: true, role: "participant")
      end
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

    # Get ParticipantEvent from an event
    # ====== Params:
    # +event+:: +Event+ to find ParticipantEvent
    # Returns ParticipantEvent found or nil if not exist ParticipantEvent
    def get_participant_event(event)
      unless event.nil?
        return ParticipantEvent.find_by_event_id_and_schedule_id(event.id, self.id)
      end
    end

    # Create a relationship between a user and route
    # ====== Params:
    # +event+:: +Event+ to get route
    # Returns Route added in event
    def relation_user_route event
      return if event.nil? or event.route.nil?

      self.user.routes << event.route
      event.route.save
    end
  end
end
