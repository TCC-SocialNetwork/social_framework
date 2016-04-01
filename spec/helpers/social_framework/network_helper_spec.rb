require 'rails_helper'

module SocialFramework
  RSpec.describe NetworkHelper, type: :helper do
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

      @user1.create_relationship @user2, "r1", true, true
      @user1.create_relationship @user2, "r2", true, true
      @user1.create_relationship @user3, "r1", true, true
      @user1.create_relationship @user4, "r1", true, true
      @user1.create_relationship @user7, "r1", true, true
      @user1.create_relationship @user8, "r1", true, true

      @user2.create_relationship @user4, "r1", true, true
      @user2.create_relationship @user5, "r1", true, true

      @user3.create_relationship @user4, "r1", true, true

      @user4.create_relationship @user5, "r2", true, true
      @user4.create_relationship @user6, "r1", true, true

      @user5.create_relationship @user6, "r1", true, true
      @user5.create_relationship @user7, "r2", true, true

      @user6.create_relationship @user7, "r1", true, true
      @user6.create_relationship @user8, "r1", true, true
      @user6.create_relationship @user9, "r1", true, true

      @graph = NetworkHelper::Graph.get_instance @user1.id
      @graph.instance_variable_set :@root, @user1
    end

    describe "Get edges from an user" do
      it "When id is 0" do
        result = @graph.send(:get_edges, 0, "all")

        expect(result).to be_empty
      end

      it "When relationships is empty" do
        result = @graph.send(:get_edges, @user1.id, [])
        expect(result).to be_empty
      end

      it "When can be any relationship" do
        result = @graph.send(:get_edges, @user1.id, "all")
        
        expect(result.count).to be(6)
      end

      it "When create inactive relationships" do
        @user1.create_relationship @user5, "r1"
        result = @graph.send(:get_edges, @user1.id, "all")
        
        expect(result.count).to be(6)
      end

      it "When can be any relationship in specfic array" do
        result = @graph.send(:get_edges, @user1.id, ["r1", "r2"])
        expect(result.count).to be(6)

        result = @graph.send(:get_edges, @user1.id, ["r1", "r3"])
        expect(result.count).to be(5)

        result = @graph.send(:get_edges, @user1.id, "r2")
        expect(result.count).to be(1)

        result = @graph.send(:get_edges, @user1.id, "r1")
        expect(result.count).to be(5)

        result = @graph.send(:get_edges, @user1.id, "r3")
        expect(result.count).to be(0)
      end
      
      it "When edge it has been visited" do
        result = @graph.send(:get_edges, @user1.id, "all")
        expect(result.count).to be(6)
        
        @graph.network << NetworkHelper::Vertex.new(@user1.id)

        result = @graph.send(:get_edges, @user2.id, "all")
        expect(result.count).to be(2)
      end

      it "When pass relationships invalid" do
        result = @graph.send(:get_edges, @user1.id, "invalid")
        expect(result.count).to be(0)
      end

      it "When pass relationships invalid and valid" do
        result = @graph.send(:get_edges, @user1.id, ["invalid", "r2"])
        expect(result.count).to be(1)
      end
    end

    describe "Mount network" do
      it "When use default depth" do
        @graph.build @user1

        expect(@graph.network.count).to be(8)

        expect(@graph.network.select { |v| v.id == 1 }.first.edges.count).to be(5)
        expect(@graph.network.select { |v| v.id == 2 }.first.edges.count).to be(3)
        expect(@graph.network.select { |v| v.id == 3 }.first.edges.count).to be(2)
        expect(@graph.network.select { |v| v.id == 4 }.first.edges.count).to be(5)
        expect(@graph.network.select { |v| v.id == 5 }.first.edges.count).to be(3)
        expect(@graph.network.select { |v| v.id == 6 }.first.edges.count).to be(3)
        expect(@graph.network.select { |v| v.id == 7 }.first.edges.count).to be(3)
        expect(@graph.network.select { |v| v.id == 8 }.first.edges.count).to be(2)

        labels = ["r1", "r2"]
        intersection = @graph.network.first.edges.first.labels & labels
        expect(intersection.count).to be(labels.count)
      end

      it "When use depth equal 1" do
        @graph.depth = 1
        @graph.build @user1
        expect(@graph.network.count).to be(1)

        expect(@graph.network.select { |v| v.id == 1 }.first.edges).to be_empty
      end

      it "When use depth equal 2" do
        @graph.depth = 2
        @graph.build @user1
        expect(@graph.network.count).to be(6)
        
        expect(@graph.network.select { |v| v.id == 1 }.first.edges.count).to be(5)
        expect(@graph.network.select { |v| v.id == 2 }.first.edges.count).to be(1)
        expect(@graph.network.select { |v| v.id == 3 }.first.edges.count).to be(1)
        expect(@graph.network.select { |v| v.id == 4 }.first.edges.count).to be(1)
        expect(@graph.network.select { |v| v.id == 7 }.first.edges.count).to be(1)
        expect(@graph.network.select { |v| v.id == 8 }.first.edges.count).to be(1)
      end

      it "When use depth equal 4" do
        @graph.depth = 4
        @graph.build @user1
        expect(@graph.network.count).to be(9)

        expect(@graph.network.select { |v| v.id == 1 }.first.edges.count).to be(5)
        expect(@graph.network.select { |v| v.id == 2 }.first.edges.count).to be(3)
        expect(@graph.network.select { |v| v.id == 3 }.first.edges.count).to be(2)
        expect(@graph.network.select { |v| v.id == 4 }.first.edges.count).to be(5)
        expect(@graph.network.select { |v| v.id == 5 }.first.edges.count).to be(4)
        expect(@graph.network.select { |v| v.id == 6 }.first.edges.count).to be(5)
        expect(@graph.network.select { |v| v.id == 7 }.first.edges.count).to be(3)
        expect(@graph.network.select { |v| v.id == 8 }.first.edges.count).to be(2)
        expect(@graph.network.select { |v| v.id == 9 }.first.edges.count).to be(1)
      end

      it "When use default attributes" do
        @graph.build @user1

        @graph.network.each do |vertex|
          expect(vertex.attributes.keys.include?(:username)).to be(true)
          expect(vertex.attributes.keys.include?(:email)).to be(true)
        end
      end

      it "When pass valid attributes" do
        @graph.build @user1, [:username, :email]

        @graph.network.each do |vertex|
          expect(vertex.attributes.key?(:username)).to be(true)
          expect(vertex.attributes.key?(:email)).to be(true)
        end
      end

      it "When pass invalid and valid attributes" do
        @graph.build @user1, [:username, :email, :invalid_attribute]

        @graph.network.each do |vertex|
          expect(vertex.attributes.key?(:username)).to be(true)
          expect(vertex.attributes.key?(:email)).to be(true)
          expect(vertex.attributes.key?(:invalid_attribute)).to be(false)
        end
      end

      it "When pass invalid attributes" do
        @graph.build @user1, [:invalid_attribute]

        @graph.network.each do |vertex|
          expect(vertex.attributes).to be_empty
        end
      end
    end

    describe "Suggest relationships" do
      before(:each) do
        @graph.build @user1
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
        @graph = NetworkHelper::Graph.get_instance @user6.id
        @graph.instance_variable_set :@root, @user6
        @graph.build @user6

        result = @graph.suggest_relationships "r1", 3

        expect(result.count).to be(1)
        expect(result.first.id).to be(1)
      end
    end

    describe "Search vertices" do
      before(:each) do
        @graph.build @user1, [:username, :email]
      end

      it "Clean all vertices" do
        @graph.network.first.color = :black

        @graph.send(:clean_vertices)

        expect(@graph.network.first.color).to be(:white)
      end

      it "Compare vertices" do
        vertex = @graph.network[0]
        result = @graph.send(:compare_vertex, vertex, {id: 1})

        expect(result).to be(true)

        result = @graph.send(:compare_vertex, vertex, {id: 0})

        expect(result).to be(false)
      end

      it "When compare vertices with attribute string" do
        vertex = @graph.network[0]
        result = @graph.send(:compare_vertex, vertex, {username: "user1"})

        expect(result).to be(true)

        result = @graph.send(:compare_vertex, vertex, {username: "user0"})

        expect(result).to be(false)
      end

      it "When pass part of string" do
        vertex = @graph.network[0]
        result = @graph.send(:compare_vertex, vertex, {username: "1"})

        expect(result).to be(true)

        result = @graph.send(:compare_vertex, vertex, {username: "0"})

        expect(result).to be(false)
      end

      it "When users_number should be 0" do
        map = {id: 1}
        result = @graph.search map, false, 0
        expect(result).to be_empty
      end

      it "When pass invalid attribute" do
        map = {invalid: 1}
        result = @graph.search map
        expect(result).to be_empty
      end

      it "When pass valid and invalid attribute" do
        map = {id: 1, invalid: 1}
        result = @graph.search map
        expect(result.count).to be(1)
      end

      it "When vertex exist" do
        map = {id: 1}
        result = @graph.search map
        expect(result.count).to be(1)
      end

      it "When vertex not exist" do
        map = {id: 0}
        result = @graph.search map
        expect(result).to be_empty
      end

      it "When vertex not exist in Graph" do
        map = {id: 9}
        result = @graph.search map
        expect(result.count).to be(1)
      end

      it "When continue search" do
        map = {username: "user"}
        
        result = @graph.search(map, false, 1)
        expect(result.count).to be(1)

        result = @graph.search(map, true, 2)
        expect(result.count).to be(3)
      end

      it "When search finished" do
        map = {username: "user"}
        
        result = @graph.search map, false, 1
        expect(result.count).to be(1)

        result = @graph.search map, true, 8
        expect(result.count).to be(9)

        result = @graph.search map, true, 3
        expect(result.count).to be(9)
      end

      it "When pass part of string" do
        map = {username: "u"}
        
        result = @graph.search map, false, 5
        expect(result.count).to be(5)

        result = @graph.search map, true, 5
        expect(result.count).to be(9)
      end

      it "When pass block time" do
        map = {username: "user"}
        
        result = @graph.search map, false, 1
        expect(result.count).to be(1)

        result = @graph.search(map, true) { |number| number *= 2 }
        expect(result.count).to be(2)

        result = @graph.search(map, true) { |number| number *= 2 }
        expect(result.count).to be(4)

        result = @graph.search(map, true) { |number| number *= 2 }
        expect(result.count).to be(8)

        result = @graph.search(map, true) { |number| number *= 2 }
        expect(result.count).to be(9)
      end

      it "When pass block sum" do
        map = {username: "user"}
        
        result = @graph.search map, false, 1
        expect(result.count).to be(1)

        result = @graph.search(map, true) { |number| number += 3 }
        expect(result.count).to be(4)

        result = @graph.search(map, true) { |number| number += 3 }
        expect(result.count).to be(7)

        result = @graph.search(map, true) { |number| number += 3 }
        expect(result.count).to be(9)
      end
    end

    describe "Search in database" do
      before(:each) do
        @graph.build @user1, [:username, :email]
        @graph.send(:clean_vertices)
      end

      it "When search with part of string" do
        map = {id: 1, username: "u"}
        
        @graph.instance_variable_set :@users_number, 5
        @graph.send(:search_in_database, map)
        expect(@graph.instance_variable_get(:@users_found).count).to be(5)

        @graph.instance_variable_set :@users_number, 9
        @graph.send(:search_in_database, map)
        expect(@graph.instance_variable_get(:@users_found).count).to be(9)

        @graph.instance_variable_set :@users_number, 10
        @graph.send(:search_in_database, map)
        expect(@graph.instance_variable_get(:@users_found).count).to be(9)
      end

      it "When search with string" do
        map = {username: "user1"}
        
        @graph.instance_variable_set :@users_number, 5
        @graph.send(:search_in_database, map)
        expect(@graph.instance_variable_get(:@users_found).count).to be(1)
      end

      it "When search with integer" do
        map = {id: 3}
        
        @graph.instance_variable_set :@users_number, 5
        @graph.send(:search_in_database, map)
        expect(@graph.instance_variable_get(:@users_found).count).to be(1)
      end
    end
  end
end
