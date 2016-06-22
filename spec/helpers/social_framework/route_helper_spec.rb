require 'rails_helper'

module SocialFramework
  RSpec.describe RouteHelper, type: :helper do
    before(:each) do
      @origin = build(:origin)
      @destiny = build(:destiny)

      @locations1 = [{latitude: -15.797780000000001, longitude: -47.866920000000007},
                    {latitude: -15.796500000000002, longitude: -47.870970000000007},
                    {latitude: -15.797780000000001, longitude: -47.866920000000007},
                    {latitude: -15.796730000000002, longitude: -47.870250000000006},
                    {latitude: -15.796220000000002, longitude: -47.871860000000005},
                    {latitude: -15.795960000000001, longitude: -47.872670000000006},
                    {latitude: -15.795840000000002, longitude: -47.873080000000002},
                    {latitude: -15.795440000000001, longitude: -47.874340000000004},
                    {latitude: -15.795020000000001, longitude: -47.875680000000003}]
        
        @locations2 = [{latitude: -15.795940000000002, longitude: -47.866440000000004},
                    {latitude: -15.794480000000002, longitude: -47.871050000000004},
                    {latitude: -15.793580000000002, longitude: -47.873950000000001},
                    {latitude: -15.793360000000002, longitude: -47.874620000000007},
                    {latitude: -15.793300000000002, longitude: -47.874700000000004},
                    {latitude: -15.793240000000001, longitude: -47.874860000000005},
                    {latitude: -15.793200000000001, longitude: -47.874960000000002},
                    {latitude: -15.793140000000001, longitude: -47.875010000000003},
                    {latitude: -15.793130000000001, longitude: -47.875060000000005},
                    {latitude: -15.793120000000002, longitude: -47.875140000000002},
                    {latitude: -15.793140000000001, longitude: -47.875180000000007},
                    {latitude: -15.793070000000002, longitude: -47.875450000000001},
                    {latitude: -15.793050000000001, longitude: -47.875590000000003},
                    {latitude: -15.792740000000002, longitude: -47.876360000000005},
                    {latitude: -15.792520000000001, longitude: -47.876900000000006}]

      @locations3 = [{latitude: -15.792740000000002, longitude: -47.876360000000005},
                  {latitude: -15.792520000000001, longitude: -47.876900000000006}]

      user1 = create(:user)
      user2 = create(:user2)

      @route1 = user1.create_route("route1", 1000, @locations1)
      @route2 = user2.create_route("route2", 1200, @locations2)
      @route3 = user2.create_route("route3", 63, @locations3)

      @route_utils = SocialFramework::RouteHelper::RouteStrategyDefault.new
    end

    describe "Get distance beteewn two locations from a mode of travel" do
      it "When origin and destiny are ok" do
        result = @route_utils.send(:get_distance, @origin, @destiny, "driving")

        expect(result).to be(2275)
      end

      it "When pass mode of travel" do
        result = @route_utils.send(:get_distance, @origin, @destiny, "walking")

        expect(result).to be(1213)

        result = @route_utils.send(:get_distance, @origin, @destiny, "bicycling")

        expect(result).to be(1562)
      end

      it "When pass an invalid param" do
        result = @route_utils.send(:get_distance, nil, @destiny, "walking")
        expect(result).to be_nil

        result = @route_utils.send(:get_distance, @origin, nil, "walking")
        expect(result).to be_nil

        result = @route_utils.send(:get_distance, @origin, @destiny, "invalid")
        expect(result).to be(2275)

        @origin = build(:origin, latitude: 400)
        result = @route_utils.send(:get_distance, @origin, @destiny, "driving")
        expect(result).to be_nil
      end
    end

    describe "Get distance beteewn two locations with waypoints" do
      it "With one waypoint" do
        waypoints = [@route2.locations.first]
        result = @route_utils.send(:get_distance_with_waypoints, @route1.locations.first, @route1.locations.last, waypoints, "driving")

        expect(result).to be(4836)
      end

      it "With multiple waypoints" do
        waypoints = [@route2.locations.first, @route2.locations.last]
        result = @route_utils.send(:get_distance_with_waypoints, @route1.locations.first, @route1.locations.last, waypoints, "driving")

        expect(result).to be(5299)
      end
    end

    describe "Check location" do
      it "When location is valid" do
        result = @route_utils.send(:check_latitude_longitude, @origin)
        expect(result).to be(true)
      end

      it "When location is nil" do
        result = @route_utils.send(:check_latitude_longitude, nil)
        expect(result).to be(false)
      end

      it "When latitude or longitude is valid" do

        @origin = build(:origin, latitude: 400)
        result = @route_utils.send(:check_latitude_longitude, @origin)
        expect(result).to be(false)

        @origin = build(:origin, longitude: 400)
        result = @route_utils.send(:check_latitude_longitude, @origin)
        expect(result).to be(false)

        @origin = build(:origin, longitude: "400")
        result = @route_utils.send(:check_latitude_longitude, @origin)
        expect(result).to be(false)
      end
    end

    describe "Calculate the distance beteewn two locations" do
      it "When origin and destiny are valid" do
        result = @route_utils.send(:haversine_distance, @origin, @destiny)
        expect(result).to be(925)
      end

      it "When origin or destiny are invalid" do
        @origin = build(:origin, latitude: 400)
        result = @route_utils.send(:haversine_distance, @origin, @destiny)
        expect(result).to be(nil)

        @origin = build(:origin)
        @destiny = build(:destiny, longitude: 900)
        result = @route_utils.send(:haversine_distance, @origin, @destiny)
        expect(result).to be(nil)

        result = @route_utils.send(:haversine_distance, @origin, nil)
        expect(result).to be(nil)

        @destiny = build(:destiny)
        result = @route_utils.send(:haversine_distance, nil, @destiny)
        expect(result).to be(nil)

        result = @route_utils.send(:haversine_distance, nil, nil)
        expect(result).to be(nil)
      end
    end

    describe "Get near points" do
      it "When have near points" do
        @route2.accepted_deviation = 1000
        result = @route_utils.send(:near_points, @route1, @route2)
        expect(result[:origins].count).to be(9)
        expect(result[:destinations].count).to be(7)
      end

      it "When dont have near points" do
        @route2.accepted_deviation = 100
        result = @route_utils.send(:near_points, @route1, @route2)
        expect(result[:origins]).to be_empty
        expect(result[:destinations]).to be_empty
      end

      it "When don't have near points in destinations" do
        @route2.accepted_deviation = 300
        result = @route_utils.send(:near_points, @route1, @route2)
        expect(result[:origins].count).to be(2)
        expect(result[:destinations]).to be_empty
      end
    end

    describe "Compare routes" do
      it "When the principal accept both" do
        @route1.accepted_deviation = 5000
        result = @route_utils.compare_routes(@route1, @route2)

        expect(result[:compatible]).to be(true)
        expect(result[:principal_route][:deviation]).to be(:both)
        expect(result[:principal_route][:distance]).to be(5299)
        expect(result[:secondary_route][:deviation]).to be(:none)
        expect(result[:secondary_route][:distance]).to be(0)
      end

      it "When the principal accept any and secondary accept both" do
        @route1.accepted_deviation = 4000
        @route2.accepted_deviation = 1400
        @route2.mode_of_travel = "walking"

        result = @route_utils.compare_routes(@route1, @route2)

        expect(result[:compatible]).to be(true)
        expect(result[:principal_route][:deviation]).to be(:origin)
        expect(result[:principal_route][:distance]).to be(4836)
        expect(result[:secondary_route][:deviation]).to be(:destiny)
        expect(result[:secondary_route][:distance]).to be(628)
      end

      it "When the principal and secondary accept any" do
        @route1.accepted_deviation = 4000
        @route2.accepted_deviation = 650
        @route2.mode_of_travel = "walking"

        result = @route_utils.compare_routes(@route1, @route2)

        expect(result[:compatible]).to be(true)
        expect(result[:principal_route][:deviation]).to be(:origin)
        expect(result[:principal_route][:distance]).to be(4836)
        expect(result[:secondary_route][:deviation]).to be(:destiny)
        expect(result[:secondary_route][:distance]).to be(628)
      end

      it "When the principal accept origin and secondary accept any" do
        @route1.accepted_deviation = 2200
        @route3.accepted_deviation = 650
        @route3.mode_of_travel = "walking"

        result = @route_utils.compare_routes(@route1, @route3)

        expect(result[:compatible]).to be(true)
        expect(result[:principal_route][:deviation]).to be(:origin)
        expect(result[:principal_route][:distance]).to be(3184)
        expect(result[:secondary_route][:deviation]).to be(:destiny)
        expect(result[:secondary_route][:distance]).to be(628)
      end

      it "When the principal accept any and secondary accept origin" do
        @route1.accepted_deviation = 3200
        @route2.accepted_deviation = 500
        @route2.mode_of_travel = "walking"
        @route2.locations.first.destroy

        result = @route_utils.compare_routes(@route1, @route2)

        expect(result[:compatible]).to be(true)
        expect(result[:principal_route][:deviation]).to be(:destiny)
        expect(result[:principal_route][:distance]).to be(3308)
        expect(result[:secondary_route][:deviation]).to be(:origin)
        expect(result[:secondary_route][:distance]).to be(417)
      end

      it "When the principal accept any and secondary accept destiny" do
        @route1.accepted_deviation = 4000
        @route2.accepted_deviation = 630
        @route2.mode_of_travel = "walking"

        result = @route_utils.compare_routes(@route1, @route2)

        expect(result[:compatible]).to be(true)
        expect(result[:principal_route][:deviation]).to be(:origin)
        expect(result[:principal_route][:distance]).to be(4836)
        expect(result[:secondary_route][:deviation]).to be(:destiny)
        expect(result[:secondary_route][:distance]).to be(628)
      end

      it "When the principal accept none and secondary accept destiny" do
        @route1.accepted_deviation = 1000
        @route2.accepted_deviation = 630
        @route2.mode_of_travel = "walking"

        result = @route_utils.compare_routes(@route1, @route2)

        expect(result[:compatible]).to be(false)
      end

      it "When the principal accept any and secondary accept none" do
        @route1.accepted_deviation = 3000
        @route2.accepted_deviation = 500
        @route2.mode_of_travel = "walking"

        result = @route_utils.compare_routes(@route1, @route2)

        expect(result[:compatible]).to be(false)
      end
    end

    describe "Principal accept deviation" do
      it "When accept both" do
        @route1.accepted_deviation = 5000
        result = @route_utils.send(:principal_accepted_deviation, @route1, @route2)
        expect(result[:accept]).to be(:both)
      end

      it "When accept any" do
        @route1.accepted_deviation = 4000
        result = @route_utils.send(:principal_accepted_deviation, @route1, @route2)
        expect(result[:accept]).to be(:any)
      end

      it "When accept origin" do
        @route1.accepted_deviation = 2200
        result = @route_utils.send(:principal_accepted_deviation, @route1, @route3)
        expect(result[:accept]).to be(:origin)
      end

      it "When accept destiny" do
        @route1.accepted_deviation = 3000
        result = @route_utils.send(:principal_accepted_deviation, @route1, @route2)
        expect(result[:accept]).to be(:destiny)
      end

      it "When accept none" do
        @route1.accepted_deviation = 1000
        result = @route_utils.send(:principal_accepted_deviation, @route1, @route2)
        expect(result[:accept]).to be(:none)
      end
    end

    describe "Secondary accept deviation" do
      it "When accept both" do
        @route2.accepted_deviation = 1400
        @route2.mode_of_travel = "walking"
        result = @route_utils.send(:secondary_accepted_deviation, @route1, @route2)
        expect(result[:accept]).to be(:both)
      end

      it "When accept any" do
        @route2.accepted_deviation = 650
        @route2.mode_of_travel = "walking"
        result = @route_utils.send(:secondary_accepted_deviation, @route1, @route2)
        expect(result[:accept]).to be(:any)
      end

      it "When accept origin" do
        @route2.locations.first.destroy
        @route2.accepted_deviation = 500
        @route2.mode_of_travel = "walking"
        result = @route_utils.send(:secondary_accepted_deviation, @route1, @route2)
        expect(result[:accept]).to be(:origin)
      end

      it "When accept destiny" do
        @route2.accepted_deviation = 630
        @route2.mode_of_travel = "walking"
        result = @route_utils.send(:secondary_accepted_deviation, @route1, @route2)
        expect(result[:accept]).to be(:destiny)
      end

      it "When accept none" do
        @route2.accepted_deviation = 500
        @route2.mode_of_travel = "walking"
        result = @route_utils.send(:secondary_accepted_deviation, @route1, @route2)
        expect(result[:accept]).to be(:none)
      end
    end

    describe "Smallest distance" do
      it "When the params it's ok" do
        result = @route_utils.send(:smallest_distance, @route1.locations, @route2.locations.first, "walking")
        expect(result[:deviation]).to be(648)

        result = @route_utils.send(:smallest_distance, @route1.locations, @route2.locations.last, "walking")
        expect(result[:deviation]).to be(628)
      end

      it "When origin points is empty" do
        result = @route_utils.send(:smallest_distance, [], @route2.locations.first, "walking")
        expect(result[:point]).to be_nil
      end
    end

    describe "Using RouteContext" do
      before(:each) do
        @context = SocialFramework::RouteHelper::RouteContext.new SocialFramework::RouteHelper::RouteStrategyDefault
      end

      it "When the principal accept both" do
        @route1.accepted_deviation = 5000
        result = @context.compare_routes(@route1, @route2)

        expect(result[:compatible]).to be(true)
        expect(result[:principal_route][:deviation]).to be(:both)
        expect(result[:principal_route][:distance]).to be(5299)
        expect(result[:secondary_route][:deviation]).to be(:none)
        expect(result[:secondary_route][:distance]).to be(0)
      end
    end
  end
end
