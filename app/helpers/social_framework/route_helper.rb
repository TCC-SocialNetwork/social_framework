module SocialFramework
  # Module to work with routes
  module RouteHelper
    # Contains the methods to match routes
    class RouteUtils

      private

      # Get the distance between two locations
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
    end
  end
end
