require 'set'

module SocialFramework
  # Module to construct Social Network
  module NetworkHelper
    autoload :GraphElements, 'graph_elements'

    # Represent the network on a Graph, with Vertices and Edges
    class Graph
      # Array of verteces
      attr_accessor :network
      # Maximum depth graph
      attr_accessor :depth

      class << self
        protected :new
      end

      # Get graph instance to user logged
      # ====== Params:
      # +id+:: +Integer+ Id of the user logged
      # +elements_factory+:: +String+ Represent the factory class name to build
      # Returns Graph object
      def self.get_instance(id, elements_factory = ElementsFactoryDefault)
        @@instances ||= {}
        
        if @@instances[id].nil?
          @@instances[id] = Graph.new elements_factory
        end

        return @@instances[id]
      end

      # Destroy graph instance with id passed
      # ====== Params:
      # +id+:: +Integer+ Id of the user logged
      # Returns Graph instance removed
      def destroy(id)
        @@instances.delete(id)
      end

      # Mount a graph from an user
      # ====== Params:
      # +root+:: +User+ Root user to mount graph
      # +attributes+:: +Array+ Attributes will be added in vertex
      # +relationships+:: +Array+ labels to find relationships, can be multiple in array or just one in a simple String, default is "all" thats represents all relationships existing
      # Returns The graph mounted
      def build(root, attributes = SocialFramework.attributes_to_build_graph, relationships = "all")
        @root = root
        @network.clear
        vertices = Array.new

        attributes_hash = mount_attributes(attributes, root)
        vertices << {vertex: @elements_factory.create_vertex(@root.id, @root.class, attributes_hash), depth: 1}

        until vertices.empty?
          pair = vertices.shift
          current_vertex = pair[:vertex]
          @network << current_vertex

          next if pair[:depth] == @depth or current_vertex.type == SocialFramework::Event
          new_depth = pair[:depth] + 1

          edges = get_edges(current_vertex.id, relationships)

          edges.each do |edge|
            user = (edge.origin.id == current_vertex.id) ? edge.destiny : edge.origin

            add_vertex(vertices, current_vertex, new_depth, user, attributes, edge.label, edge.bidirectional)
          end

          events = get_events(current_vertex.id)
          events.each do |event|
            add_vertex(vertices, current_vertex, new_depth, event, attributes, "event", false)
          end
        end
      end

      # Search users with values specified in a map
      # ====== Params:
      # +map+:: +Hash+ with keys and values to compare
      # +search_in_progress+:: +Boolean+ to continue if true or start a new search
      # +elements_number+:: +Integer+ to limit max search result
      # Returns Set with users found
      def search(map, search_in_progress = false, elements_number = SocialFramework.elements_number_to_search)
        return {users: @users_found, events: @events_found} if @finished_search and search_in_progress == true

        unless search_in_progress
          clean_vertices
          @network.first.color = :gray
          @queue << @network.first
        end

        if block_given? and search_in_progress
          @elements_number = yield @elements_number
        else
          @elements_number += elements_number
        end

        search_visit(map) unless @finished_search_in_graph
        search_in_database(map) if (@users_found.size + @events_found.size) < @elements_number and @finished_search_in_graph
        return {users: @users_found, events: @events_found}
      end

      # Suggest relationships to root
      # ====== Params:
      # +type_relationships+:: +Array+ labels to find relationships, can be multiple in array or just one in a simple String
      # +amount_relationships+:: +Integer+ quantity of relationships to suggest a new relationship
      # Returns +Array+ with the vertices to suggestions
      def suggest_relationships(type_relationships = SocialFramework.relationship_type_to_suggest,
        amount_relationships = SocialFramework.amount_relationship_to_suggest)

        travel_in_third_depth(type_relationships) do |destiny_edge|
          destiny_edge.destiny.visits = 0
        end

        suggestions = Array.new

        travel_in_third_depth(type_relationships) do |destiny_edge|
          destiny_edge.destiny.visits = destiny_edge.destiny.visits + 1

          if(destiny_edge.destiny.visits == amount_relationships and
            destiny_edge.destiny.id != @root.id and
            @network.first.edges.select { |e| e.destiny == destiny_edge.destiny }.empty?)
            
            suggestions << @root.class.find(destiny_edge.destiny.id)
          end
        end
        return suggestions
      end

      protected

      # Init the network in Array
      # ====== Params:
      # +elements_factory+:: +String+ Represent the factory class name to build
      # Returns Graph's Instance
      def initialize elements_factory
        @elements_factory = elements_factory.new
        @network = Array.new
        @depth = SocialFramework.depth_to_build
      end

      # Select all user's edges with the relationships required
      # ====== Params:
      # +user_id+:: +Integer+ to find to get edges
      # +relationships+:: +Array+ relationships required to select edges
      # Returns Edges selected
      def get_edges(user_id, relationships)
        user = get_user user_id
        return [] if user.nil? 

        user.edges.select do |e|
          id = (e.origin.id == user.id) ? e.destiny.id : e.origin.id

          condiction_to_string = (relationships.class == String and (relationships == "all" or e.label == relationships))
          condiction_to_array = (relationships.class == Array and relationships.include? e.label)

          e.active and not @network.include? @elements_factory.create_vertex(id, user.class) and (condiction_to_string or condiction_to_array)
        end
      end

      # Get all user's events confirmed
      # ====== Params:
      # +user_id+:: +Integer+ to find to get edges
      # Returns Events found
      def get_events(user_id)
        user = get_user user_id
        return [] if user.nil?

        unless user_id == @root.id
          query = "social_framework_participant_events.schedule_id = ? AND " +
            "social_framework_participant_events.confirmed = ? AND " +
            "social_framework_events.particular = ?"
          SocialFramework::Event.joins(:participant_events).where(query, user.schedule.id,
            true, false).order(start: :desc)
        else
          query = "social_framework_participant_events.schedule_id = ? AND " +
            "social_framework_participant_events.confirmed = ?"
          SocialFramework::Event.joins(:participant_events).where(query, user.schedule.id,
            true).order(start: :desc)
        end
      end

      # Get user by id
      # ====== Params:
      # +user_id+:: +Integer+ to find
      # Returns Events found
      def get_user(user_id)
        begin
          return @root.class.find user_id
        rescue
          return nil
        end
      end

      # Add vertex in queue
      # ====== Params:
      # +vertices+:: +Array+ elements queue
      # +current_vertex+:: +Vertex+ to add edges
      # +depth+:: +Integer+ current depth in graph
      # +element+:: +User+ or +Event+ to add in queue
      # +attributes+:: +Hash+ attributes required
      # +label+:: +String+ edge label
      # +bidirectional+:: +Boolean+ if true create two edges
      # Returns Events found
      def add_vertex(vertices, current_vertex, depth, element, attributes, label, bidirectional)
        pair = vertices.select { |p| p[:vertex].id == element.id and p[:vertex].type == element.class }.first

        if pair.nil?
          attributes_hash = mount_attributes(attributes, element)
          new_vertex = @elements_factory.create_vertex(element.id, element.class, attributes_hash)
        else
          new_vertex = pair[:vertex]
        end
        current_vertex.add_edge new_vertex, label
        new_vertex.add_edge current_vertex, label if bidirectional

        if pair.nil? and not @network.include? new_vertex
          vertices << {vertex: new_vertex, depth: depth}
        end
      end

      # Travel neighbor neighbor
      # ====== Params:
      # +type_relationships+:: +Array+ labels to find relationships, can be multiple in array or just one in a simple String
      # +yield+:: +Block+ to execute when it is on the third level
      # Returns Nil
      def travel_in_third_depth(type_relationships)
        type_relationships = [type_relationships] if type_relationships.class == String

        edges = @network.first.edges.select {|e| not (e.labels & type_relationships).empty?}

        edges.each do |edge|
          destiny_edges = edge.destiny.edges.select {|e| not (e.labels & type_relationships).empty?}

          destiny_edges.each do |destiny_edge|
            yield destiny_edge
          end
        end
      end

      # Visit vertices in Graph fiding specifcs vertices
      # ====== Params:
      # +map+:: +Hash+ with keys and values to compare
      # Returns Nil
      def search_visit(map)
        while not @queue.empty? and (@users_found.size + @events_found.size) < @elements_number do
          root = @queue.pop
          if compare_vertex(root, map)
            if root.type == SocialFramework::User
              @users_found << root.type.find(root.id)
            elsif root.type == SocialFramework::Event
              @events_found << root.type.find(root.id)
            end
          end

          root.edges.each do |edge|
            vertex = edge.destiny
            if vertex.color == :white
              vertex.color = :gray 
              @queue << vertex
            end
          end
          root.color = :black
        end

        @finished_search_in_graph = @queue.empty?
      end

      # Verify if vertex contains some attribute with values passed in map
      # ====== Params:
      # +vertex+:: +Vertex+ to compare
      # +map+:: +Hash+ with keys and values to compare
      # Returns true if vertex contains some falue or false if not
      def compare_vertex(vertex, map)
        map.each do |key, value|
          vertex_value = vertex.respond_to?(key) ? vertex.method(key).call : nil

          if value.class == String
            condictions = ((not vertex_value.nil? and vertex_value.include? value) or
              (not vertex.attributes[key].nil? and vertex.attributes[key].downcase.include? value.downcase))
          else
            condictions = ((vertex_value == value) or vertex.attributes[key] == value)
          end

          return true if condictions
        end

        return false
      end

      # Set color white to all vertices in graph
      # Returns @network with white vertices
      def clean_vertices
        @finished_search_in_graph = false
        @finished_search = false
        @users_found = Set.new
        @events_found = Set.new
        @queue = Queue.new
        @users_in_database = nil
        @events_in_database = nil
        @elements_number = 0

        @network.each do |vertex|
          vertex.color = :white
        end
      end

      # Mount Hash with required attributes
      # ====== Params:
      # +attributes+:: +Array+ required attributes
      # +element+:: +Object+ to get the value of attributes
      # Returns a Hash of attributes and values
      def mount_attributes(attributes, element)
        hash = Hash.new

        attributes.each do |a|
          if (element.respond_to? a)
            hash[a] = element.method(a).call
          else
            Rails.logger.warn "The #{element.class.name} haven't the attribute #{a}"
          end
        end
        return hash
      end

      # Continue search in database
      # ====== Params:
      # +map+:: +Hash+ with keys and values to compare
      # Returns Nil
      def search_in_database(map)
        user_condictions = build_condictions(map, SocialFramework::User)
        event_condictions = build_condictions(map, SocialFramework::Event)

        begin
          if user_condictions != "()"
            @users_in_database ||= SocialFramework::User.where([user_condictions, map]).to_a

            while (@users_found.size + @events_found.size) < @elements_number and not @users_in_database.empty?
              @users_found << @users_in_database.shift
            end
          end

          if((@users_found.size + @events_found.size) < @elements_number and
            event_condictions != "()")
            map[:particular] = false
            event_condictions += " AND particular = :particular"
            @events_in_database ||= SocialFramework::Event.where([event_condictions, map]).to_a

            while (@users_found.size + @events_found.size) < @elements_number and not @events_in_database.empty?
              @events_found << @events_in_database.shift
            end
            @finished_search = @events_in_database.empty?
          end
        rescue
          Rails.logger.warn "Parameter invalid!"
        end
      end

      # Create condictions to search in database
      # ====== Params:
      # +map+:: +Hash+ with keys and values to compare
      # +_class+:: +Object+ type class to create condictions
      # Returns condictions built
      def build_condictions(map, _class)
        condictions = "("
        
        map.each do |key, value|
          next unless _class.instance_methods.include?(key)
          comparator = (value.class == String ? "LIKE" : "=")
          column = (value.class == String ? "lower(#{key})" : "#{key}")
          condictions += " OR " if condictions.size > 1
          condictions += "#{column} #{comparator} :#{key}"
          map[key] = "%#{value.downcase}%" if value.class == String
        end

        return (condictions + ")")
      end
    end
  end
end
