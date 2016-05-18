module SocialFramework
  # Module to work with routes
  module RouteHelper
    # Contains the methods to match routes
    class RouteUtils

      private

      # Get the distance between two locations from a mode of travel
      # ====== Params:
      # +origin+:: +Location+ departure point
      # +destiny+:: +Location+ arrival point
      # Returns Integer distance in meters or nil if couldn't make a request
      def get_distance(origin, destiny, mode_of_travel = "driving")
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
      # +maximum_deviation+:: +Integer+ maximum deviation to who hitchhike
      # Returns Hash with origins and destinations points
      def near_points(principal_route, secondary_route, maximum_deviation = SocialFramework.maximum_deviation)
        origin = secondary_route.locations.first
        destiny = secondary_route.locations.last

        origins = Array.new
        destinations = Array.new

        principal_route.locations.each do |location|
          distance_origin = haversine_distance(location, origin)
          distance_destiny = haversine_distance(location, destiny)

          origins << location if (not distance_origin.nil?) and distance_origin <= maximum_deviation
          destinations << location if (not distance_destiny.nil?) and distance_destiny <= maximum_deviation
        end

        return {origins: origins, destinations: destinations}
      end
    end
  end
end
