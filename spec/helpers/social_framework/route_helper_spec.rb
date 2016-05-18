require 'rails_helper'

module SocialFramework
  RSpec.describe RouteHelper, type: :helper do
    before(:each) do
      @origin = build(:origin)
      @destiny = build(:destiny)

      @route_utils = SocialFramework::RouteHelper::RouteUtils.new
    end

    describe "Get distace beteewn two locations" do
      it "When origin and destiny are ok" do
        result = @route_utils.send(:get_distance, @origin, @destiny)

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
        result = @route_utils.send(:get_distance, @origin, @destiny)
        expect(result).to be_nil
      end
    end
  end
end
