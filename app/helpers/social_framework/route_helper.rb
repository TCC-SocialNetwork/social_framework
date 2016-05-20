module SocialFramework
  # Module to work with routes
  module RouteHelper
    # Contains the methods to match routes
    class RouteUtils

      def comparete_routes(principal_route, secondary_route,
          principal_deviation = SocialFramework.principal_deviation,
          secondary_deviation = SocialFramework.secondary_deviation)

          accepted_deviation = secondary_accepted_deviation(principal_route, secondary_route,
            secondary_deviation[:deviation], secondary_deviation[:mode])
      end

      private

      # Verify the deviations which can be made on secondary route
      # ====== Params:
      # +principal_route+:: +Route+ who gives a lift
      # +secondary_route+:: +Route+ who hitchhike
      # +deviatoin+:: +Integer+ maximum deviation accepeted to secondary route
      # +mode_of_travel+:: +String+ specify mode of travel
      # Returns Hash with point and smallest deviation
      def secondary_accepted_deviation(principal_route, secondary_route, deviation, mode_of_travel = "walking")
        points = near_points(principal_route, secondary_route, deviation)
        origin_deviation = smallest_distance(points[:origins], secondary_route.locations.first, mode_of_travel)
        destiny_deviation = smallest_distance(points[:destinations], secondary_route.locations.last, mode_of_travel)
        
        if(deviation >= origin_deviation[:deviation] + destiny_deviation[:deviation])
          return {accept: :both, distance_origin: origin_deviation[:deviation], distance_destiny: destiny_deviation[:deviation]}
        elsif(deviation >= origin_deviation[:deviation] and deviation >= destiny_deviation[:deviation])
          return {accept: :any, distance_origin: origin_deviation[:deviation], distance_destiny: destiny_deviation[:deviation]}
        elsif(deviation >= origin_deviation[:deviation])
          return {accept: :origin, distance: origin_deviation[:deviation]}
        elsif(deviation >= destiny_deviation[:deviation])
          return {accept: :destiny, distance: destiny_deviation[:deviation]}
        end
        return {accept: :none}
      end

      # Get the origin point with the smallest distance to specific destiny
      # ====== Params:
      # +origin_points+:: +Array+ with the departure points
      # +destiny+:: +Location+ arrival point
      # +mode_of_travel+:: +String+ specify mode of travel
      # Returns Hash with point and smallest deviation
      def smallest_distance(origin_points, destiny, mode_of_travel)
        smallest_distance = nil
        origin_point = nil

        origin_points.each do |origin|
          distance = get_distance(origin, destiny, mode_of_travel)
          if smallest_distance.nil? or distance < smallest_distance
            origin_point = origin
            smallest_distance = distance
          end
        end

        return {point: origin_point, deviation: smallest_distance}
      end

      # Get the distance between two locations with waypoints
      # ====== Params:
      # +origin+:: +Location+ departure point
      # +destiny+:: +Location+ arrival point
      # +waypoints+:: +Array+ with intermediates points
      # +mode_of_travel+:: +String+ specify mode of travel
      # Returns Integer distance in meters or nil if couldn't make a request
      def get_distance_with_waypoints(origin, destiny, waypoints, mode_of_travel)
        begin
          origin = "#{origin.latitude},#{origin.longitude}"
          destination = "#{destiny.latitude},#{destiny.longitude}"
          
          waypoint = ""
          waypoints.each do |w|
            waypoint += "|" unless waypoint.empty?
            waypoint += "#{w.latitude},#{w.longitude}"
          end

          params = "mode=#{mode_of_travel}&origin=#{origin}&destination=#{destination}&waypoints=#{waypoint}"
          
          url = URI.parse("https://maps.googleapis.com/maps/api/directions/json?#{params}")

          response = Net::HTTP.get_response(url)
        rescue
          Rails.logger.warn "Couldn't make request"
          return
        end

        if (not response.nil?) and response.code == "200" and JSON(response.body)["status"] == "OK"
          distance = 0
          JSON(response.body)["routes"].first["legs"].each do |leg|
            distance += leg["distance"]["value"]
          end
          return distance
        end
      end

      # Get the distance between two locations from a mode of travel
      # ====== Params:
      # +origin+:: +Location+ departure point
      # +destiny+:: +Location+ arrival point
      # +mode_of_travel+:: +String+ specify mode of travel
      # Returns Integer distance in meters or nil if couldn't make a request
      def get_distance(origin, destiny, mode_of_travel)
        begin
          origins = "#{origin.latitude},#{origin.longitude}"
          destinations = "#{destiny.latitude},#{destiny.longitude}"

          params = "mode=#{mode_of_travel}&origins=#{origins}&destinations=#{destinations}"
          
          url = URI.parse("https://maps.googleapis.com/maps/api/distancematrix/json?#{params}")

          response = Net::HTTP.get_response(url)
        rescue
          Rails.logger.warn "Couldn't make request"
          return
        end

        if (not response.nil?) and response.code == "200" and JSON(response.body)["rows"].first["elements"].first["status"] == "OK"
          return JSON(response.body)["rows"].first["elements"].first["distance"]["value"]
        end
      end

      # Calculate the distance between two point
      # ====== Params:
      # +origin+:: +Location+ departure point
      # +destiny+:: +Location+ arrival point
      # Returns Double distance in meters or nil if couldn't calculate
      def haversine_distance(origin, destiny)
        return unless check_latitude_longitude(origin) and check_latitude_longitude(destiny)

        rad_per_deg = 0.017453293
        raius_in_meters = 6371000

        origin_latitude = origin.latitude * rad_per_deg
        origin_longitude = origin.longitude * rad_per_deg

        destiny_latitude = destiny.latitude * rad_per_deg
        destiny_logitude = destiny.longitude * rad_per_deg

        delta_longitude = destiny_logitude - origin_longitude
        delta_latitude = destiny_latitude - origin_latitude

        a = (Math.sin(delta_latitude/2))**2 + Math.cos(origin_latitude) *
             Math.cos(destiny_latitude) * (Math.sin(delta_longitude/2))**2
        c = 2 * Math.atan2( Math.sqrt(a), Math.sqrt(1-a))

        return (raius_in_meters * c).round
      end

      # Check if a location have a valid latitude and longitude
      # ====== Params:
      # +location+:: +Location+ to check
      # Returns True if location is valid or False if no
      def check_latitude_longitude(location)
        return ((not location.nil?) and location.latitude <= 180 and location.latitude >= -180 and
          location.longitude <= 90 and location.longitude >= -90)
      end

      # Get near points to origin and destiny of secondary route 
      # ====== Params:
      # +principal_route+:: +Route+ who gives a lift
      # +secondary_route+:: +Route+ who hitchhike
      # +secondary_maximum_deviation+:: +Integer+ maximum deviation to who hitchhike
      # Returns Hash with origins and destinations points
      def near_points(principal_route, secondary_route, secondary_maximum_deviation)
        origin = secondary_route.locations.first
        destiny = secondary_route.locations.last

        origins = Array.new
        destinations = Array.new

        principal_route.locations.each do |location|
          distance_origin = haversine_distance(location, origin)
          distance_destiny = haversine_distance(location, destiny)

          origins << location if (not distance_origin.nil?) and distance_origin <= secondary_maximum_deviation
          destinations << location if (not distance_destiny.nil?) and distance_destiny <= secondary_maximum_deviation
        end

        return {origins: origins, destinations: destinations}
      end
    end
  end
end
