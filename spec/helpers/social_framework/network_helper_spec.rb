require 'rails_helper'

module SocialFramework
  RSpec.describe NetworkHelper, type: :helper do
    
    describe "Get relationships to mount graph" do
      before(:all) do
        @r1 = create(:relationship, label: "r1")
        @r2 = create(:relationship, label: "r2")
        @r3 = create(:relationship, label: "r3")
        @graph = NetworkHelper::Graph.new
      end
      
      it "When get all relationships" do
        result = @graph.send(:get_relationships, "all")
        expect(result.count).to be(3)
      end

      it "When get just one relationship" do
        result = @graph.send(:get_relationships, "r1")
        expect(result.count).to be(1)
        expect(result.first.label).to eq("r1")
      end

      it "When multiple relationships" do
        result = @graph.send(:get_relationships, ["r1", "r3"])
        expect(result.count).to be(2)
        expect(result.first.label).to eq("r1")
        expect(result.last.label).to eq("r3")
      end

      it "When pass an invalid relationship" do
        result = @graph.send(:get_relationships, "invalid")
        expect(result).to be_empty
      end

      it "When pass invalid and valid relationships" do
        result = @graph.send(:get_relationships, ["r1", "invalid"])
        expect(result.count).to be(1)
        expect(result.first.label).to eq("r1")
      end
    end

    describe "Get edges from an user" do
      before(:each) do
        @user = create(:user)
        @user2 = create(:user2)
        @user3 = create(:user3)

        @user.create_relationship(@user2, "r1")
        @user.create_relationship(@user2, "r2")

        @user.create_relationship(@user3, "r2")
        @user.create_relationship(@user3, "r3")

        @graph = NetworkHelper::Graph.new
      end

      it "When edges is empty" do
        relationships = @graph.send(:get_relationships, "all")
        result = @graph.send(:get_edges, [], relationships, false)

        expect(result).to be_empty
      end

      it "When relationships is empty" do
        result = @graph.send(:get_edges, @user.edges, [], false)
        expect(result).to be_empty
      end

      it "When can be any relationship" do
        relationships = @graph.send(:get_relationships, "all")
        result = @graph.send(:get_edges, @user.edges, relationships, false)
        
        expect(result.count).to be(@user.edges.count)
      end

      it "When can be any relationship in specfic array" do
        relationships = @graph.send(:get_relationships, ["r1", "r2"])
        result = @graph.send(:get_edges, @user.edges, relationships, false)
        expect(result.count).to be(@user.edges.count)

        relationships = @graph.send(:get_relationships, ["r1", "r3"])
        result = @graph.send(:get_edges, @user.edges, relationships, false)
        expect(result.count).to be(@user.edges.count)

        relationships = @graph.send(:get_relationships, "r2")
        result = @graph.send(:get_edges, @user.edges, relationships, false)
        expect(result.count).to be(@user.edges.count)

        relationships = @graph.send(:get_relationships, "r1")
        result = @graph.send(:get_edges, @user.edges, relationships, false)
        expect(result.count).to be(1)

        relationships = @graph.send(:get_relationships, "r3")
        result = @graph.send(:get_edges, @user.edges, relationships, false)
        expect(result.count).to be(1)
      end

      it "When edge must be all relationships" do
        relationships = @graph.send(:get_relationships, "all")
        result = @graph.send(:get_edges, @user.edges, relationships, true)
        expect(result).to be_empty

        relationships = @graph.send(:get_relationships, ["r1", "r2"])
        result = @graph.send(:get_edges, @user.edges, relationships, true)
        expect(result.count).to be(1)

        relationships = @graph.send(:get_relationships, ["r1", "r3"])
        result = @graph.send(:get_edges, @user.edges, relationships, true)
        expect(result).to be_empty

        relationships = @graph.send(:get_relationships, "r2")
        result = @graph.send(:get_edges, @user.edges, relationships, true)
        expect(result.count).to be(@user.edges.count)

        relationships = @graph.send(:get_relationships, "r1")
        result = @graph.send(:get_edges, @user.edges, relationships, true)
        expect(result.count).to be(1)

        relationships = @graph.send(:get_relationships, "r3")
        result = @graph.send(:get_edges, @user.edges, relationships, true)
        expect(result.count).to be(1)
      end
    end
  end
end
