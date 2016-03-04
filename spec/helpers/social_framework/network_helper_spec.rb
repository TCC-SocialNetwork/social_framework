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
      
      it "When edge it has been visited" do
        relationships = @graph.send(:get_relationships, "all")
        
        @graph.send(:add_vertex, @user)
        @graph.send(:get_edges, @user.edges, relationships, false)

        result = @graph.send(:get_edges, @user.edges, relationships, false)
        expect(result.count).to be(@user.edges.count)
        
        @graph.send(:add_vertex, @user2)
        result = @graph.send(:get_edges, @user2.edges, relationships, false)
        expect(result.count).to be(0)
      end
    end

    describe "Add vertex" do
      before(:each) do
        @user = create(:user)
        @user2 = create(:user2)

        @graph = NetworkHelper::Graph.new
      end

      it "When user is invalid" do
        result = @graph.send(:add_vertex, nil)
        expect(result).to be_nil
        expect(@graph.network).to be_empty

        user3 = build(:user3, id: nil)
        @graph.send(:add_vertex, user3)
        expect(result).to be_nil
        expect(@graph.network).to be_empty
      end

      it "When user is valid" do
        @graph.send(:add_vertex, @user)
        expect(@graph.network.count).to be(1)

        @graph.send(:add_vertex, @user2)
        expect(@graph.network.count).to be(2)
      end

      it "When user is duplicated" do
        @graph.send(:add_vertex, @user)
        expect(@graph.network.count).to be(1)

        @graph.send(:add_vertex, @user)
        expect(@graph.network.count).to be(1)
      end
    end

    describe "Populate network" do
      before(:each) do
        @user = create(:user)
        @user2 = create(:user,username: "user2", email: "user2@mail.com")
        @user3 = create(:user,username: "user3", email: "user3@mail.com")
        @user4 = create(:user,username: "user4", email: "user4@mail.com")
        @user5 = create(:user,username: "user5", email: "user5@mail.com")

        @user.create_relationship @user2, "r1"
        @user.create_relationship @user3, "r1"

        @user2.create_relationship @user4, "r1"

        @user3.create_relationship @user4, "r1"
        @user4.create_relationship @user5, "r1"

        @graph = NetworkHelper::Graph.new
        @root_vertex = @graph.send(:add_vertex, @user)
        @relationships = @graph.send(:get_relationships, "all")
      end

      it "When use default depth" do
        @graph.send(:populate_network, @root_vertex, @user, @relationships, false, 1)
        expect(@graph.network.count).to be(5)

        expect(@graph.network.select { |v| v.id == 1 }.first.edges.count).to be(2)
        expect(@graph.network.select { |v| v.id == 2 }.first.edges.count).to be(1)
        expect(@graph.network.select { |v| v.id == 3 }.first.edges).to be_empty
        expect(@graph.network.select { |v| v.id == 4 }.first.edges.count).to be(2)
        expect(@graph.network.select { |v| v.id == 5 }.first.edges).to be_empty
      end

      it "When use depth equal 1" do
        @graph.depth = 1
        @graph.send(:populate_network, @root_vertex, @user, @relationships, false, 1)
        expect(@graph.network.count).to be(3)
      end

      it "When use depth equal 2" do
        @graph.depth = 2
        @graph.send(:populate_network, @root_vertex, @user, @relationships, false, 1)
        expect(@graph.network.count).to be(4)
      end
    end
  end
end
