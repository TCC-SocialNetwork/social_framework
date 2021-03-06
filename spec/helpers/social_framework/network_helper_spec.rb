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

      @graph = NetworkHelper::GraphStrategyDefault.get_instance @user1.id, ElementsFactoryDefault
      @graph.instance_variable_set :@root, @user1
      @graph.network = Array.new
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
        
        @graph.network << GraphElements::VertexDefault.new(@user1.id, @user1.class)

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

        expect(@graph.network.select { |v| v.id == @user1.id }.first.edges.count).to be(5)
        expect(@graph.network.select { |v| v.id == @user2.id }.first.edges.count).to be(3)
        expect(@graph.network.select { |v| v.id == @user3.id }.first.edges.count).to be(2)
        expect(@graph.network.select { |v| v.id == @user4.id }.first.edges.count).to be(5)
        expect(@graph.network.select { |v| v.id == @user5.id }.first.edges.count).to be(3)
        expect(@graph.network.select { |v| v.id == @user6.id }.first.edges.count).to be(3)
        expect(@graph.network.select { |v| v.id == @user7.id }.first.edges.count).to be(3)
        expect(@graph.network.select { |v| v.id == @user8.id }.first.edges.count).to be(2)

        labels = ["r1", "r2"]
        intersection = @graph.network.first.edges.first.labels & labels
        expect(intersection.count).to be(labels.count)
      end

      it "When use depth equal 1" do
        @graph.depth = 1
        @graph.build @user1
        expect(@graph.network.count).to be(1)

        expect(@graph.network.select { |v| v.id == @user1.id }.first.edges).to be_empty
      end

      it "When use depth equal 2" do
        @graph.depth = 2
        @graph.build @user1
        expect(@graph.network.count).to be(6)
        
        expect(@graph.network.select { |v| v.id == @user1.id }.first.edges.count).to be(5)
        expect(@graph.network.select { |v| v.id == @user2.id }.first.edges.count).to be(1)
        expect(@graph.network.select { |v| v.id == @user3.id }.first.edges.count).to be(1)
        expect(@graph.network.select { |v| v.id == @user4.id }.first.edges.count).to be(1)
        expect(@graph.network.select { |v| v.id == @user7.id }.first.edges.count).to be(1)
        expect(@graph.network.select { |v| v.id == @user8.id }.first.edges.count).to be(1)
      end

      it "When use depth equal 4" do
        @graph.depth = 4
        @graph.build @user1
        expect(@graph.network.count).to be(9)

        expect(@graph.network.select { |v| v.id == @user1.id }.first.edges.count).to be(5)
        expect(@graph.network.select { |v| v.id == @user2.id }.first.edges.count).to be(3)
        expect(@graph.network.select { |v| v.id == @user3.id }.first.edges.count).to be(2)
        expect(@graph.network.select { |v| v.id == @user4.id }.first.edges.count).to be(5)
        expect(@graph.network.select { |v| v.id == @user5.id }.first.edges.count).to be(4)
        expect(@graph.network.select { |v| v.id == @user6.id }.first.edges.count).to be(5)
        expect(@graph.network.select { |v| v.id == @user7.id }.first.edges.count).to be(3)
        expect(@graph.network.select { |v| v.id == @user8.id }.first.edges.count).to be(2)
        expect(@graph.network.select { |v| v.id == @user9.id }.first.edges.count).to be(1)
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

      it "When users have events" do
        start = DateTime.new(2016, 01, 01, 8, 0, 0)
        event1 = @user1.schedule.create_event("Event1", start, 1.hour)
        event2 = @user1.schedule.create_event("Event2", start + 1.hour, 1.hour)
        
        @user2.schedule.enter_in_event event2
        @user7.schedule.enter_in_event event1

        event3 = @user2.schedule.create_event("Event3", start + 2.hour, 1.hour)

        @user3.schedule.enter_in_event event3

        event4 = @user4.schedule.create_event("Event4", start + 3.hour, 1.hour)

        @user5.schedule.enter_in_event event4

        event5 = @user5.schedule.create_event("Event5", start + 4.hour, 1.hour)

        @user6.schedule.enter_in_event event5

        @graph.depth = 3
        @graph.build @user1

        expect(@graph.network.count).to be(12)

        expect(@graph.network[0].type).to eq(SocialFramework::User)
        expect(@graph.network[0].id).to be(@user1.id)
        expect(@graph.network[1].type).to eq(SocialFramework::User)
        expect(@graph.network[1].id).to be(@user2.id)
        expect(@graph.network[2].type).to eq(SocialFramework::User)
        expect(@graph.network[2].id).to be(@user3.id)
        expect(@graph.network[3].type).to eq(SocialFramework::User)
        expect(@graph.network[3].id).to be(@user4.id)
        expect(@graph.network[4].type).to eq(SocialFramework::User)
        expect(@graph.network[4].id).to be(@user7.id)
        expect(@graph.network[5].type).to eq(SocialFramework::User)
        expect(@graph.network[5].id).to be(@user8.id)

        expect(@graph.network[6].type).to eq(SocialFramework::Event)
        expect(@graph.network[6].id).to be(event2.id)
        expect(@graph.network[7].type).to eq(SocialFramework::Event)
        expect(@graph.network[7].id).to be(event1.id)

        expect(@graph.network[8].type).to eq(SocialFramework::User)
        expect(@graph.network[8].id).to be(@user5.id)

        expect(@graph.network[9].type).to eq(SocialFramework::Event)
        expect(@graph.network[9].id).to be(event3.id)

        expect(@graph.network[10].type).to eq(SocialFramework::User)
        expect(@graph.network[10].id).to be(@user6.id)

        expect(@graph.network[11].type).to eq(SocialFramework::Event)
        expect(@graph.network[11].id).to be(event4.id)
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
        expect(result.first.id).to be(@user6.id)
      end

      it "With correct erelationship and three common relationships" do
        result = @graph.suggest_relationships "r1", 3

        expect(result.count).to be(1)
        expect(result.first.id).to be(@user6.id)
      end

      it "With pass multiple relationships" do
        result = @graph.suggest_relationships ["r1", "r2"], 3

        expect(result.count).to be(2)
        expect(result.first.id).to be(@user5.id)
        expect(result.last.id).to be(@user6.id)
      end

      it "With user6 as root" do
        @graph = NetworkHelper::GraphStrategyDefault.get_instance @user6.id, ElementsFactoryDefault
        @graph.instance_variable_set :@root, @user6
        @graph.build @user6

        result = @graph.suggest_relationships "r1", 3

        expect(result.count).to be(1)
        expect(result.first.id).to be(@user1.id)
      end
    end

    describe "Compare vertex" do
      before(:each) do
        @graph.build @user1, [:username, :email, :title]
      end

      it "Clean all vertices" do
        @graph.network.first.color = :black

        @graph.send(:clean_vertices)

        expect(@graph.network.first.color).to be(:white)
      end

      it "Compare vertices" do
        vertex = @graph.network[0]
        result = @graph.send(:compare_vertex, vertex, {id: @user1.id})

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
    end

    describe "Search vertices" do
      before(:each) do
        start = DateTime.new(2016, 01, 01, 8, 0, 0)
        @event1 = @user1.schedule.create_event("Event1", start, 1.hour)
        @event2 = @user1.schedule.create_event("Event2", start + 1.hour, 1.hour)
        
        @user2.schedule.enter_in_event @event2
        @user7.schedule.enter_in_event @event1

        @event3 = @user2.schedule.create_event("Event3", start + 2.hour, 1.hour)

        @user3.schedule.enter_in_event @event3

        @event4 = @user4.schedule.create_event("Event4", start + 3.hour, 1.hour)

        @user5.schedule.enter_in_event @event4

        @event5 = @user5.schedule.create_event("Event5", start + 4.hour, 1.hour)

        @user6.schedule.enter_in_event @event5

        @graph.build @user1, [:username, :email, :title]
      end

      it "When elements_number should be 0" do
        map = {id: @user1.id}
        result = @graph.search map, false, 0
        expect(result[:users]).to be_empty
        expect(result[:events]).to be_empty
      end

      it "When pass invalid attribute" do
        map = {invalid: 1}
        result = @graph.search map
        expect(result[:users]).to be_empty
        expect(result[:events]).to be_empty
      end

      it "When pass valid and invalid attribute" do
        map = {id: @user1.id, invalid: 1}
        result = @graph.search map
        expect(result[:users].count).to be(1)
        map = {id: @event1.id, invalid: 1}
        result = @graph.search map
        expect(result[:events].count).to be(1)
      end

      it "When vertex exist" do
        map = {id: @user1.id}
        result = @graph.search map
        expect(result[:users].count).to be(1)
        map = {id: @event1.id}
        result = @graph.search map
        expect(result[:events].count).to be(1)
      end

      it "When vertex not exist" do
        map = {id: 0}
        result = @graph.search map
        expect(result[:users]).to be_empty
        expect(result[:events]).to be_empty
      end

      it "When vertex not exist in Graph" do
        map = {id: @user9.id}
        result = @graph.search map
        expect(result[:users].count).to be(1)
        expect(result[:events]).to be_empty
      end

      it "When continue search" do
        map = {username: "user", title: "event"}
        
        result = @graph.search(map, false, 1)
        expect(result[:users].count).to be(1)
        expect(result[:events]).to be_empty

        result = @graph.search(map, true, 6)
        expect(result[:users].count).to be(6)
        expect(result[:events].count).to be(1)
      end

      it "When search finished" do
        map = {username: "user", title: "event"}
        
        result = @graph.search map, false, 1
        expect(result[:users].count).to be(1)
        expect(result[:events]).to be_empty

        result = @graph.search map, true, 8
        expect(result[:users].count).to be(7)
        expect(result[:events].count).to be(2)

        result = @graph.search map, true, 3
        expect(result[:users].count).to be(8)
        expect(result[:events].count).to be(4)

        result = @graph.search map, true, 10
        expect(result[:users].count).to be(9)
        expect(result[:events].count).to be(5)
      end

      it "When pass part of string" do
        map = {username: "U", title: "e"}
        
        result = @graph.search map, false, 5
        expect(result[:users].count).to be(5)
        expect(result[:events]).to be_empty

        result = @graph.search map, true, 5
        expect(result[:users].count).to be(7)
        expect(result[:events].count).to be(3)
      end

      it "When pass multiplier block" do
        map = {username: "user", title: "event"}
        
        result = @graph.search map, false, 1
        expect(result[:users].count).to be(1)
        expect(result[:events]).to be_empty

        result = @graph.search(map, true) { |number| number *= 2 }
        expect(result[:users].count).to be(2)
        expect(result[:events]).to be_empty

        result = @graph.search(map, true) { |number| number *= 2 }
        expect(result[:users].count).to be(4)
        expect(result[:events]).to be_empty

        result = @graph.search(map, true) { |number| number *= 2 }
        expect(result[:users].count).to be(6)
        expect(result[:events].count).to be(2)

        result = @graph.search(map, true) { |number| number *= 2 }
        expect(result[:users].count).to be(9)
        expect(result[:events].count).to be(5)
      end

      it "When pass adder block" do
        map = {username: "user", title: "event"}
        
        result = @graph.search map, false, 1
        expect(result[:users].count).to be(1)
        expect(result[:events]).to be_empty

        result = @graph.search(map, true) { |number| number += 3 }
        expect(result[:users].count).to be(4)
        expect(result[:events]).to be_empty

        result = @graph.search(map, true) { |number| number += 3 }
        expect(result[:users].count).to be(6)
        expect(result[:events].count).to be(1)

        result = @graph.search(map, true) { |number| number += 3 }
        expect(result[:users].count).to be(7)
        expect(result[:events].count).to be(3)
      end

      it "When exist private events" do
        start = DateTime.new(2016, 01, 02, 8, 0, 0)
        @user1.schedule.create_event("Event1", start, 1.hour, "desc", true)
        @user2.schedule.create_event("Event2", start, 1.hour, "desc", true)

        @graph.build @user1, [:username, :email, :title]

        map = {username: "user", title: "event"}
        
        result = @graph.search map, false, 1
        expect(result[:users].count).to be(1)
        expect(result[:events]).to be_empty

        result = @graph.search map, true, 8
        expect(result[:users].count).to be(6)
        expect(result[:events].count).to be(3)

        result = @graph.search map, true, 3
        expect(result[:users].count).to be(8)
        expect(result[:events].count).to be(4)

        result = @graph.search map, true, 10
        expect(result[:users].count).to be(9)
        expect(result[:events].count).to be(6)
      end
    end

    describe "Search in database" do
      before(:each) do
        @graph.build @user1, [:username, :email]
        @graph.send(:clean_vertices)
      end

      it "When search with part of string" do
        map = {id: @user1.id, username: "u"}
        
        @graph.instance_variable_set :@elements_number, 5
        @graph.send(:search_in_database, map)
        expect(@graph.instance_variable_get(:@users_found).count).to be(5)

        @graph.instance_variable_set :@elements_number, 9
        @graph.send(:search_in_database, map)
        expect(@graph.instance_variable_get(:@users_found).count).to be(9)

        @graph.instance_variable_set :@elements_number, 10
        @graph.send(:search_in_database, map)
        expect(@graph.instance_variable_get(:@users_found).count).to be(9)
      end

      it "When search with string" do
        map = {username: "user1"}
        
        @graph.instance_variable_set :@elements_number, 5
        @graph.send(:search_in_database, map)
        expect(@graph.instance_variable_get(:@users_found).count).to be(1)
      end

      it "When search with integer" do
        map = {id: @user3.id}
        
        @graph.instance_variable_set :@elements_number, 5
        @graph.send(:search_in_database, map)
        expect(@graph.instance_variable_get(:@users_found).count).to be(1)
      end
    end

    describe "Get events" do
      it "When all events is public" do
        start = DateTime.new(2016, 01, 01, 8, 0, 0)
        event1 = @user1.schedule.create_event("Event1", start, 1.hour)
        event2 = @user1.schedule.create_event("Event2", start + 1.hour, 1.hour)

        events = @graph.send(:get_events, @user1.id)

        expect(events.count).to be(2)
        expect(events.first).to eq(event2)
        expect(events.last).to eq(event1)
      end

      it "When root has private events" do
        start = DateTime.new(2016, 01, 01, 8, 0, 0)
        event1 = @user1.schedule.create_event("Event1", start, 1.hour, "Description1", true)
        event2 = @user1.schedule.create_event("Event2", start + 1.hour, 1.hour)

        events = @graph.send(:get_events, @user1.id)

        expect(events.count).to be(2)
        expect(events.first).to eq(event2)
        expect(events.last).to eq(event1)
      end

      it "When common user has private events" do
        start = DateTime.new(2016, 01, 01, 8, 0, 0)
        event1 = @user2.schedule.create_event("Event1", start, 1.hour, "Description1", true)
        event2 = @user2.schedule.create_event("Event2", start + 1.hour, 1.hour)

        events = @graph.send(:get_events, @user2.id)

        expect(events.count).to be(1)
        expect(events.first).to eq(event2)
      end
    end

    describe "Get user" do
      it "When pass a valid id" do
        user = @graph.send(:get_user, @user1.id)

        expect(user).to eq(@user1)
      end

      it "When pass an invalid id" do
        user = @graph.send(:get_user, nil)

        expect(user).to be_nil

        user = @graph.send(:get_user, 100)

        expect(user).to be_nil
      end
    end

    describe "Add vertex" do
      it "When the queue is empty" do
        vertices = Array.new
        current_vertex = GraphElements::VertexDefault.new(@user1.id, @user1.class)
        @graph.send(:add_vertex, vertices, current_vertex, 1, @user2, [], "r1", true)

        expect(vertices.count).to be(1)
        expect(vertices.first[:vertex].id).to be(@user2.id)
        
        expect(vertices.first[:vertex].edges.count).to be(1)
        expect(vertices.first[:vertex].edges.first.destiny).to eq(current_vertex)

        expect(current_vertex.edges.count).to be(1)
        expect(current_vertex.edges.first.destiny).to eq(vertices.first[:vertex])
      end

      it "When the user is in queue" do
        current_vertex = GraphElements::VertexDefault.new(@user1.id, @user1.class)
        vertex_user2 = GraphElements::VertexDefault.new(@user2.id, @user2.class)

        vertices = Array.new
        
        vertices << {vertex: vertex_user2, depth: 2}

        expect(vertices.count).to be(1)
        expect(vertices.first[:vertex].id).to be(@user2.id)

        @graph.send(:add_vertex, vertices, current_vertex, 2, @user2, [], "r1", true)

        expect(vertices.count).to be(1)
        expect(vertices.first[:vertex]).to eq(vertex_user2)
        
        expect(vertices.first[:vertex].edges.count).to be(1)
        expect(vertices.first[:vertex].edges.first.destiny).to eq(current_vertex)

        expect(current_vertex.edges.count).to be(1)
        expect(current_vertex.edges.first.destiny).to eq(vertices.first[:vertex])
      end

      it "When the user already is in graph" do
        current_vertex = GraphElements::VertexDefault.new(@user1.id, @user1.class)
        vertex_user2 = GraphElements::VertexDefault.new(@user2.id, @user2.class)

        vertices = Array.new
        
        @graph.network << vertex_user2

        expect(vertices.count).to be(0)

        @graph.send(:add_vertex, vertices, current_vertex, 2, @user2, [], "r1", true)

        expect(vertices.count).to be(0)
        expect(current_vertex.edges.first.destiny).to eq(@graph.network.first)
      end
    end

    describe "Build condictions" do
      it "When pass valid atributes" do
        map = {username: "user", email: "user"}
        result = @graph.send(:build_condictions, map, SocialFramework::User)

        expect(result).to eq("(lower(username) LIKE :username OR lower(email) LIKE :email)")
      end

      it "When pass valid and invalid atributes" do
        map = {username: "user", email: "user", invalid: "invalid"}
        result = @graph.send(:build_condictions, map, SocialFramework::User)

        expect(result).to eq("(lower(username) LIKE :username OR lower(email) LIKE :email)")
      end

      it "When pass invalid atributes" do
        map = {invalid: "invalid"}
        result = @graph.send(:build_condictions, map, SocialFramework::User)

        expect(result).to eq("()")
      end

      it "When pass a empty map" do
        result = @graph.send(:build_condictions, {}, SocialFramework::User)

        expect(result).to eq("()")
      end
    end

    describe "Using GraphContext" do
      before(:each) do
        @context = NetworkHelper::GraphContext.new @user1.id
      end

      it "Build Graph When use default depth" do
        @context.build @user1

        expect(@context.graph.network.count).to be(8)

        expect(@context.graph.network.select { |v| v.id == @user1.id }.first.edges.count).to be(5)
        expect(@context.graph.network.select { |v| v.id == @user2.id }.first.edges.count).to be(3)
        expect(@context.graph.network.select { |v| v.id == @user3.id }.first.edges.count).to be(2)
        expect(@context.graph.network.select { |v| v.id == @user4.id }.first.edges.count).to be(5)
        expect(@context.graph.network.select { |v| v.id == @user5.id }.first.edges.count).to be(3)
        expect(@context.graph.network.select { |v| v.id == @user6.id }.first.edges.count).to be(3)
        expect(@context.graph.network.select { |v| v.id == @user7.id }.first.edges.count).to be(3)
        expect(@context.graph.network.select { |v| v.id == @user8.id }.first.edges.count).to be(2)

        labels = ["r1", "r2"]
        intersection = @context.graph.network.first.edges.first.labels & labels
        expect(intersection.count).to be(labels.count)
      end

      it "Search Vertices When vertex exist" do
        @context.build @user1

        map = {id: @user1.id}
        result = @context.search map
        
        expect(result[:users].count).to be(1)
        expect(result[:events].count).to be(0)
      end

      it "Suggest Relationships With correct relationship and three common relationships" do
        @context.build @user1
        result = @context.suggest_relationships "r1", 3

        expect(result.count).to be(1)
        expect(result.first.id).to be(@user6.id)
      end
    end
  end
end
