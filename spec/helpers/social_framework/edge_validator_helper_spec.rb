require 'rails_helper'

module SocialFramework
  RSpec.describe EdgeValidatorHelper, type: :helper do
    describe "Edge Validator" do
      it "When not exist edges" do
        edge = build(:edge)
        expect(edge.destiny_must_be_unique_to_same_origin).to be_nil
      end

      it "When exist outhers edges" do
        create(:edge, origin: create(:user), destiny: create(:user2))
        edge = build(:edge) 
        expect(edge.destiny_must_be_unique_to_same_origin).to be_nil
      end

      it "When exist same edge" do
        user = create(:user)
        user2 = create(:user2)
        create(:edge, origin: user, destiny: user2)
        edge = build(:edge, origin: user, destiny: user2)
        edge.destiny_must_be_unique_to_same_origin

        expect(edge.errors).not_to be_empty
      end
    end
  end
end
