module SocialFramework
  # Module to construct Schedule Graph
  module ScheduleHelper
    autoload :GraphElements, 'graph_elements'

    # Represent the schedule on a Graph, with Vertices and Edges
    class Graph
      attr_accessor :slots

      # Init the slots and users in Array
      # ====== Params:
      # +max_duration+:: +ActiveSupport::Duration+ used to define max finish day to build graph
      # Returns Graph's Instance
      def initialize max_duration = SocialFramework.max_duration_to_schedule_graph
        @slots = Array.new
        @users = Array.new
        @max_duration = max_duration
      end

      # Init the slots and users in Array
      # ====== Params:
      # +start_day+:: +Date+ start day to get slots
      # +finish_day+:: +Date+ finish day to get slots
      # +start_hour+:: +Time+ start hour at each day to get slots
      # +finish_hour+:: +Time+ finsh hour at each day to get slots
      # +slots_size+:: +Integer+ slots size duration
      # Returns The Graph mounted
      def build(start_day, finish_day, start_hour, finish_hour, users, slots_size = SocialFramework.slots_size)
        return unless finish_day_ok? start_day, finish_day

        @slots_size = slots_size
        start_time = start_day.to_datetime + start_hour.seconds_since_midnight.seconds
        finish_time = finish_day.to_datetime + finish_hour.seconds_since_midnight.seconds

        build_slots(start_time, finish_time, start_hour, finish_hour, slots_size)
        @users = users

        build_edges(start_time, finish_time)
      end

      private

      # Verify if finish day is between start day and max duration
      # ====== Params:
      # +start_day+:: +Date+ start day to get slots
      # +finish_day+:: +Date+ finish day to get slots
      # Returns true is ok or false if no
      def finish_day_ok?(start_day, finish_day)
        finish = start_day + @max_duration
        return finish_day <= finish
      end

      # Build slots whitin a period of time
      # ====== Params:
      # +current_time+:: +Datetime+ start date to build slots
      # +finish_time+:: +Datetime+ finish date to build slots
      # +start_time+:: +Time+ start hour in days to build slots
      # +finish_time+:: +Time+ finish hour in days to build slots
      # +slots_size+:: +Integer+ slots size duration
      # Returns schedule graph with slots
      def build_slots(current_time, finish_time, start_hour, finish_hour, slots_size)
        while current_time < finish_time
          verterx = GraphElements::Vertex.new(current_time)
          @slots << verterx

          current_time += slots_size

          if current_time.seconds_since_midnight >= finish_hour.seconds_since_midnight
            current_time = current_time.beginning_of_day + start_hour.seconds_since_midnight.seconds + 1.day
          end
        end
      end

      # Build edges to schedule graph
      # ====== Params:
      # +start_time+:: +Datetime+ used to get events with that start date
      # +finish_time+:: +Datetime+ used to get events with that finish date
      # Returns Schedule graph with edges between slots and users
      def build_edges(start_time, finish_time)
        @users.each do |user|
          events = user.schedule.events_in_period(start_time, finish_time)
          i = 0

          @slots.each do |slot|
            if events.empty?
              slot.add_edge(user)
            else
              if slot_empty?(slot, events[i])
                slot.add_edge(user)
              end

              if (slot.id + @slots_size).to_datetime >= events[i].finish.to_datetime and events[i] != events.last
                i += 1
              end
            end
          end
        end
      end

      # Verify if event match with a slot
      # ====== Params:
      # +slot+:: +Vertex+ represent a slot in schedule built
      # Returns true if match or false if no
      def slot_empty?(slot, event)
        return ((slot.id + @slots_size).to_datetime <= event.start.to_datetime or
          slot.id >= event.finish.to_datetime)
      end
    end
  end
end
