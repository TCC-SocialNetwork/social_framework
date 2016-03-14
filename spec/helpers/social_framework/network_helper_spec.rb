require 'rails_helper'

module SocialFramework
  RSpec.describe NetworkHelper, type: :helper do
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

      it "When id is 0" do
        result = @graph.send(:get_edges, 0, "all")

        expect(result).to be_empty
      end

      it "When relationships is empty" do
        result = @graph.send(:get_edges, @user.id, [])
        expect(result).to be_empty
      end

      it "When can be any relationship" do
        result = @graph.send(:get_edges, @user.id, "all")
        
        expect(result.count).to be(@user.edges.count)
      end

      it "When can be any relationship in specfic array" do
        result = @graph.send(:get_edges, @user.id, ["r1", "r2"])
        expect(result.count).to be(3)

        result = @graph.send(:get_edges, @user.id, ["r1", "r3"])
        expect(result.count).to be(2)

        result = @graph.send(:get_edges, @user.id, "r2")
        expect(result.count).to be(2)

        result = @graph.send(:get_edges, @user.id, "r1")
        expect(result.count).to be(1)

        result = @graph.send(:get_edges, @user.id, "r3")
        expect(result.count).to be(1)
      end
      
      it "When edge it has been visited" do
        @graph.send(:add_vertex, @user)

        result = @graph.send(:get_edges, @user.id, "all")
        expect(result.count).to be(4)
        
        @graph.send(:add_vertex, @user2)
        result = @graph.send(:get_edges, @user2.id, "all")
        expect(result.count).to be(0)
      end

      it "When pass relationships invalid" do
        @graph.send(:add_vertex, @user)

        result = @graph.send(:get_edges, @user.id, "invalid")
        expect(result.count).to be(0)
      end

      it "When pass relationships invalid and valid" do
        @graph.send(:add_vertex, @user)

        result = @graph.send(:get_edges, @user.id, ["invalid", "r2"])
        expect(result.count).to be(2)
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
    end

    describe "Populate network" do
      before(:each) do
        @user = create(:user)
        @user2 = create(:user,username: "user2", email: "user2@mail.com")
        @user3 = create(:user,username: "user3", email: "user3@mail.com")
        @user4 = create(:user,username: "user4", email: "user4@mail.com")
        @user5 = create(:user,username: "user5", email: "user5@mail.com")

        @user.create_relationship @user2, "r1"
        @user.create_relationship @user2, "r2"
        @user.create_relationship @user3, "r1"

        @user2.create_relationship @user4, "r1", false, false # unidirectional

        @user3.create_relationship @user4, "r1"
        @user4.create_relationship @user5, "r1"

        @graph = NetworkHelper::Graph.new
        @graph.instance_variable_set :@root, @user
      end

      it "When use default depth" do
        @graph.send(:populate_network, "all")
        expect(@graph.network.count).to be(4)

        expect(@graph.network.select { |v| v.id == 1 }.first.edges.count).to be(2)
        expect(@graph.network.select { |v| v.id == 2 }.first.edges.count).to be(2)
        expect(@graph.network.select { |v| v.id == 3 }.first.edges.count).to be(2)
        expect(@graph.network.select { |v| v.id == 4 }.first.edges.count).to be(1)

        labels = ["r1", "r2"]
        intersection = @graph.network.first.edges.first.labels & labels
        expect(intersection.count).to be(labels.count)
      end

      it "When use depth equal 1" do
        @graph.depth = 1
        @graph.send(:populate_network, "all")
        expect(@graph.network.count).to be(1)

        expect(@graph.network.select { |v| v.id == 1 }.first.edges).to be_empty
      end

      it "When use depth equal 2" do
        @graph.depth = 2
        @graph.send(:populate_network, "all")
        expect(@graph.network.count).to be(3)

        expect(@graph.network.select { |v| v.id == 1 }.first.edges.count).to be(2)
        expect(@graph.network.select { |v| v.id == 2 }.first.edges.count).to be(1)
        expect(@graph.network.select { |v| v.id == 3 }.first.edges.count).to be(1)
      end

      it "When use depth equal 4" do
        @graph.depth = 4
        @graph.send(:populate_network, "all")
        expect(@graph.network.count).to be(5)

        expect(@graph.network.select { |v| v.id == 1 }.first.edges.count).to be(2)
        expect(@graph.network.select { |v| v.id == 2 }.first.edges.count).to be(2)
        expect(@graph.network.select { |v| v.id == 3 }.first.edges.count).to be(2)
        expect(@graph.network.select { |v| v.id == 4 }.first.edges.count).to be(2)
        expect(@graph.network.select { |v| v.id == 5 }.first.edges.count).to be(1)
      end
    end

    describe "Suggest relationships" do
      before(:each) do
        @user1 = create(:user,username: "user1", email: "user1@mail.com")
        @user2 = create(:user,username: "user2", email: "user2@mail.com")
        @user3 = create(:user,username: "user3", email: "user3@mail.com")
        @user4 = create(:user,username: "user4", email: "user4@mail.com")
        @user5 = create(:user,username: "user5", email: "user5@mail.com")
        @user6 = create(:user,username: "user6", email: "user6@mail.com")
        @user7 = create(:user,username: "user7", email: "user7@mail.com")
        @user8 = create(:user,username: "user8", email: "user8@mail.com")
        @user9 = create(:user,username: "user9", email: "user9@mail.com")

        @user1.create_relationship @user2, "r1"
        @user1.create_relationship @user3, "r1"
        @user1.create_relationship @user4, "r1"
        @user1.create_relationship @user7, "r1"
        @user1.create_relationship @user8, "r1"

        @user2.create_relationship @user4, "r1"
        @user2.create_relationship @user5, "r1"

        @user3.create_relationship @user4, "r1"

        @user4.create_relationship @user5, "r2"
        @user4.create_relationship @user6, "r1"

        @user5.create_relationship @user6, "r1"
        @user5.create_relationship @user7, "r2"

        @user6.create_relationship @user7, "r1"
        @user6.create_relationship @user8, "r1"
        @user6.create_relationship @user9, "r1"

        @graph = NetworkHelper::Graph.new
        @graph.instance_variable_set :@root, @user1
        @graph.mount_graph @user1
      end

      it "With default params" do
        result = @graph.suggest_relationships

        expect(result).to be_empty
      end

      it "With correct relationship" do
        result = @graph.suggest_relationships "r1"

        expect(result).to be_empty
      end

      it "When call multiple times" do
        result = @graph.suggest_relationships "r1", 3
        result = @graph.suggest_relationships "r1", 3

        expect(result.count).to be(1)
        expect(result.first.id).to be(6)
      end

      it "With correct erelationship and three common relationships" do
        result = @graph.suggest_relationships "r1", 3

        expect(result.count).to be(1)
        expect(result.first.id).to be(6)
      end

      it "With pass multiple relationships" do
        result = @graph.suggest_relationships ["r1", "r2"], 3

        expect(result.count).to be(2)
        expect(result.first.id).to be(5)
        expect(result.last.id).to be(6)
      end

      it "With user6 as root" do
        @graph = NetworkHelper::Graph.new
        @graph.instance_variable_set :@root, @user6
        @graph.mount_graph @user6

        result = @graph.suggest_relationships "r1", 3

        expect(result.count).to be(1)
        expect(result.first.id).to be(1)
      end
    end
  end
end
