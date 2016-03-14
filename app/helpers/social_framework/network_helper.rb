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
      def initialize depth = SocialFramework.depth_to_mount_graph
        @network = Array.new
        @depth = depth
      end

      # Mount a graph from an user
      # ====== Params:
      # +root+:: +User+ Root user to mount graph
      # +relationships+:: +Array+ labels to find relationships, can be multiple in array or just one in a simple String, default is "all" thats represents all relationships existing
      # Returns The graph mounted
      def mount_graph(root, relationships = "all")
        @root = root
        populate_network relationships
      end

      # Suggest relationships to root
      # ====== Params:
      # +type_relationships+:: +Array+ labels to find relationships, can be multiple in array or just one in a simple String
      # +amount_relationships+:: +Integer+ quantity of relationships to suggest a new relationship
      # Returns +Array+ with the vertecies to suggestions
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
      def get_edges user_id, relationships
        begin
          user = SocialFramework::User.find user_id
        rescue
          return []
        end

        user.edges.select do |e|
          id = (e.origin.id == user.id) ? e.destiny.id : e.origin.id

          condiction_to_string = (relationships.class == String and (relationships == "all" or e.label == relationships))
          condiction_to_array = (relationships.class == Array and relationships.include? e.label)

          not @network.include? Vertex.new(id) and (condiction_to_string or condiction_to_array)
        end
      end

      # Create a new vertex with user id and add in @network
      # ====== Params:
      # +user+:: +User+ to get id
      # Returns Array network
      def add_vertex user
        return if user.nil? or user.id.nil?
        
        vertex = Vertex.new user.id
        @network << vertex
        return vertex
      end

      # Populate network with the users related 
      # ====== Params:
      # +relationships+:: +Array+ relationships required to select edges
      # Returns Array network
      def populate_network relationships
        @queue = Array.new
        @queue << {vertex: Vertex.new(@root.id), depth: 1}

        until @queue.empty?
          pair = @queue.shift
          current_vertex = pair[:vertex]
          @network << current_vertex

          next if pair[:depth] == @depth
          new_depth = pair[:depth] + 1

          edges = get_edges(current_vertex.id, relationships)

          edges.each do |e|
            user = (e.origin.id == current_vertex.id) ? e.destiny : e.origin

            pair = @queue.select { |p| p[:vertex].id == user.id }.first
            new_vertex = pair.nil? ? Vertex.new(user.id) : pair[:vertex]

            current_vertex.add_edge new_vertex, e.label
            new_vertex.add_edge current_vertex, e.label if e.bidirectional

            if pair.nil? and not @network.include? new_vertex
              @queue << {vertex: new_vertex, depth: new_depth}
            end
          end
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
    end

    # Represent graph's vertex
    class Vertex
      attr_accessor :id, :edges, :visits

      # Constructor to vertex 
      # ====== Params:
      # +id+:: +Integer+ user id
      # Returns Vertex's Instance
      def initialize id = 0
        @id = id
        @edges = Array.new
        @visits = 0
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

      def to_s
        "vertex #{id}"
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

      def to_s
        "#{@origin.id} -> #{@destiny.id}"
      end
    end
  end
end
