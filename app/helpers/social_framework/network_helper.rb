require 'set'

module SocialFramework
  # Module to construct Social Network
  module NetworkHelper

    # Represent the network on a Graph, with Vertices and Edges
    class Graph
      attr_accessor :network, :depth

      # Init the network in Array
      # ====== Params:
      # +depth+:: +Integer+ depth graph to mounted, default is value defined to 'depth_to_mount_graph' in initializer social_framework.rb
      # Returns Graph's Instance
      def initialize(depth = SocialFramework.depth_to_mount_graph)
        @network = Array.new
        @depth = depth
      end

      # Mount a graph from an user
      # ====== Params:
      # +root+:: +User+ Root user to mount graph
      # +attributes+:: +Array+ Attributes will be added in vertex
      # +relationships+:: +Array+ labels to find relationships, can be multiple in array or just one in a simple String, default is "all" thats represents all relationships existing
      # Returns The graph mounted
      def mount_graph(root, attributes = [], relationships = "all")
        @root = root

        vertices = Array.new
        attributes_hash = mount_attributes(attributes, root)
        vertices << {vertex: Vertex.new(@root.id, attributes_hash), depth: 1}

        until vertices.empty?
          pair = vertices.shift
          current_vertex = pair[:vertex]
          @network << current_vertex

          next if pair[:depth] == @depth
          new_depth = pair[:depth] + 1

          edges = get_edges(current_vertex.id, relationships)

          edges.each do |e|
            user = (e.origin.id == current_vertex.id) ? e.destiny : e.origin

            pair = vertices.select { |p| p[:vertex].id == user.id }.first

            if pair.nil?
              attributes_hash = mount_attributes(attributes, user)
              new_vertex = Vertex.new(user.id, attributes_hash)
            else
              new_vertex = pair[:vertex]
            end
            current_vertex.add_edge new_vertex, e.label
            new_vertex.add_edge current_vertex, e.label if e.bidirectional

            if pair.nil? and not @network.include? new_vertex
              vertices << {vertex: new_vertex, depth: new_depth}
            end
          end
        end
      end

      # Search users with values specified in a map
      # ====== Params:
      # +map+:: +Hash+ with keys and values to compare
      # +search_in_progress+:: +Boolean+ to continue if true or start a new search
      # +users_number+:: +Integer+ to limit max search result
      # Returns Set with users found
      def search(map, search_in_progress = false, users_number = SocialFramework.users_number_to_search)
        return @users_found if @finished_search and search_in_progress == true

        unless search_in_progress
          clean_vertices
          @network.first.color = :gray
          @queue << @network.first
        end

        search_visit map, users_number unless @finished_search_in_graph

        search_in_database(map, users_number) if @users_found.size < users_number and @finished_search_in_graph

        return @users_found
      end

      # Suggest relationships to root
      # ====== Params:
      # +type_relationships+:: +Array+ labels to find relationships, can be multiple in array or just one in a simple String
      # +amount_relationships+:: +Integer+ quantity of relationships to suggest a new relationship
      # Returns +Array+ with the vertices to suggestions
      def suggest_relationships(type_relationships = SocialFramework.relationship_type_to_suggest,
        amount_relationships = SocialFramework.amount_relationship_to_suggest)

        travel_in_third_depth(type_relationships, amount_relationships) do |destiny_edge|
          destiny_edge.destiny.visits = 0
        end

        suggestions = Array.new

        travel_in_third_depth(type_relationships, amount_relationships) do |destiny_edge|
          destiny_edge.destiny.visits = destiny_edge.destiny.visits + 1
          if destiny_edge.destiny.visits == amount_relationships and destiny_edge.destiny != @root and not @root.edges.include? destiny_edge.destiny
            suggestions << destiny_edge.destiny 
          end
        end
        return suggestions
      end

      protected

      # Select all user's edges with the relationships required
      # ====== Params:
      # +user_id+:: +User+ to find to get edges
      # +relationships+:: +Array+ relationships required to select edges
      # Returns Edges selected
      def get_edges(user_id, relationships)
        begin
          user = SocialFramework::User.find user_id
        rescue
          return []
        end

        user.edges.select do |e|
          id = (e.origin.id == user.id) ? e.destiny.id : e.origin.id

          condiction_to_string = (relationships.class == String and (relationships == "all" or e.label == relationships))
          condiction_to_array = (relationships.class == Array and relationships.include? e.label)

          e.active and not @network.include? Vertex.new(id) and (condiction_to_string or condiction_to_array)
        end
      end

      # Travel neighbor neighbor
      # ====== Params:
      # +type_relationships+:: +Array+ labels to find relationships, can be multiple in array or just one in a simple String
      # +amount_relationships+:: +Integer+ quantity of relationships to suggest a new relationship
      # +yield+:: +Block+ to execute when it is on the third level
      def travel_in_third_depth(type_relationships, amount_relationships)
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
      # +users_number+:: +Integer+ to limit max search result
      def search_visit(map, users_number)
        while not @queue.empty? and @users_found.size < users_number do
          root = @queue.pop

          @users_found << SocialFramework::User.find(root.id) if compare_vertex(root, map)

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
              (not vertex.attributes[key].nil? and vertex.attributes[key].include? value))
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
        @queue = Queue.new
        @users_in_database = nil

        @network.each do |vertex|
          vertex.color = :white
        end
      end

      # Mount Hash with required attributes
      # ====== Params:
      # +attributes+:: +Array+ required attributes
      # +user+:: +User+ to get the value of attributes
      # Returns a Hash of attributes and values
      def mount_attributes(attributes, user)
        hash = Hash.new

        attributes.each do |a|
          if (user.respond_to? a)
            hash[a] = user.method(a).call
          else
            Rails.logger.warn "The user haven't the attribute #{a}"
          end
        end
        return hash
      end

      # Continue search in database
      # ====== Params:
      # +map+:: +Hash+ with keys and values to compare
      # +users_number+:: +Integer+ to limit max search result
      def search_in_database(map, users_number)
        condictions = ""
        
        map.each do |key, value|
          comparator = value.class == String ? "LIKE" : "="
          condictions += " OR " unless condictions.empty?
          condictions += "#{key} #{comparator} :#{key}"
          map[key] = "%#{value}%" if value.class == String
        end

        begin
          @users_in_database ||= SocialFramework::User.where([condictions, map]).to_a

          @finished_search = true if @users_found.size + @users_in_database.size <= users_number 

          while @users_found.size < users_number and not @users_in_database.empty?
            @users_found << @users_in_database.shift
          end
        rescue
          Rails.logger.warn "Parameter invalid!"
        end
      end
    end

    # Represent graph's vertex
    class Vertex
      attr_accessor :id, :edges, :visits, :color, :attributes

      # Constructor to vertex 
      # ====== Params:
      # +id+:: +Integer+ user id
      # Returns Vertex's Instance
      def initialize id = 0, attributes = {}
        @id = id
        @edges = Array.new
        @visits = 0
        @color = :white
        @attributes = attributes
      end
      
      # Overriding equal method to compare vertex by id
      # Returns true if id is equal or false if not
      def ==(other)
        self.id == other.id
      end
      
      alias :eql? :==
      
      # Overriding hash method to always equals
      # Returns id hash
      def hash
        self.id.hash
      end

      # Add edges to vertex
      # ====== Params:
      # +destiny+:: +Vertex+  destiny to edge
      # +label+:: +String+  label to edge
      # Returns edge created
      def add_edge destiny, label
        edge = @edges.select { |e| e.destiny == destiny }.first

        if edge.nil?
          edge = Edge.new self, destiny
          @edges << edge
        end

        edge.labels << label
      end
    end
    
    # Represent the conneciont edges between vertices
    class Edge
      attr_accessor :origin, :destiny, :labels
      
      # Constructor to Edge 
      # ====== Params:
      # +origin+:: +Vertex+ relationship origin
      # +destiny+:: +Vertex+ relationship destiny
      # Returns Vertex's Instance
      def initialize origin, destiny
        @origin = origin
        @destiny = destiny
        @labels = Array.new
      end
    end
  end
end
