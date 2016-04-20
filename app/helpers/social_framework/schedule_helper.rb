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
      # +users+:: +Array+ users to check disponibility
      # +start_day+:: +Date+ start day to get slots
      # +finish_day+:: +Date+ finish day to get slots
      # +start_hour+:: +Time+ start hour at each day to get slots
      # +finish_hour+:: +Time+ finish hour at each day to get slots
      # +slots_size+:: +Integer+ slots size duration
      # Returns The Graph mounted
      def build(users, start_day, finish_day, start_hour = Time.parse("00:00"), finish_hour = Time.parse("23:59"), slots_size = SocialFramework.slots_size)
        return unless finish_day_ok? start_day, finish_day

        @slots_size = slots_size
        start_time = start_day.to_datetime + start_hour.seconds_since_midnight.seconds
        finish_time = finish_day.to_datetime + finish_hour.seconds_since_midnight.seconds

        build_slots(start_time, finish_time, start_hour, finish_hour)
        build_users(users)

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
      # +start_hour+:: +Time+ start hour in days to build slots
      # +finish_hour+:: +Time+ finish hour in days to build slots
      # Returns schedule graph with slots
      def build_slots(current_time, finish_time, start_hour, finish_hour)
        while current_time < finish_time
          slots_quantity = get_slots_quantity(start_hour, finish_hour)

          (1..slots_quantity).each do
            verterx = GraphElements::Vertex.new(current_time, {gained_weight: 0})
            @slots << verterx

            current_time += @slots_size
            break if current_time >= finish_time
          end

          current_time = current_time.beginning_of_day + start_hour.seconds_since_midnight.seconds + 1.day if start_hour.seconds_since_midnight > finish_hour.seconds_since_midnight
        end
      end

      # Build edges to schedule graph
      # ====== Params:
      # +start_time+:: +Datetime+ used to get events with that start date
      # +finish_time+:: +Datetime+ used to get events with that finish date
      # Returns Schedule graph with edges between slots and users
      def build_edges(start_time, finish_time)
        @users.each do |user|
          schedule = SocialFramework::Schedule.find_by_user_id user.id

          events = schedule.events_in_period(start_time, finish_time)
          i = 0

          @slots.each do |slot|
            if events.empty? or slot_empty?(slot, events[i])
              slot.add_edge(user)
              slot.attributes[:gained_weight] += user.attributes[:weight] 
            end

            if (slot.id + @slots_size).to_datetime >= events[i].finish.to_datetime and events[i] != events.last
              i += 1
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

      # Calculate the quantity of slot that fit over in a period of time
      # ====== Params:
      # +start_hour+:: +Time+ start date to build slots
      # +finish_hour+:: +Time+ finish date to build slots
      # Returns the quantity of slots
      def get_slots_quantity(start_hour, finish_hour)
        if start_hour.seconds_since_midnight <= finish_hour.seconds_since_midnight
          hours = finish_hour.seconds_since_midnight - start_hour.seconds_since_midnight
        else
          hours = start_hour.seconds_until_end_of_day + finish_hour.seconds_since_midnight + 1.second
        end
        
        return (hours / @slots_size).to_i
      end

      # Build vertecies to each user with weight
      # ====== Params:
      # +users+:: +Hash+ to add weight, key is user and value is weight, can be a simple Array, in this case all users will have the max weight
      # Returns the users vertices
      def build_users(users)
        users.each do |user, weight|
          weight = SocialFramework.max_weight_schedule if weight.nil?
          vertex = GraphElements::Vertex.new(user.id, {weight: weight})
          @users << vertex
        end
      end
    end
  end
end
