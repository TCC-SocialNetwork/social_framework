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
      # +type_relationships+:: +Array+ labels to find relationships, can be multiple in array or just one in a simple String, default is "all" thats represents all relationships existing
      # +all_relationships+:: +Boolean+ represents type selection to get edges, if is false select the edges thats have any relationship required, if true select just edges thats have all relationships required, default is false
      # Returns The graph mounted
      def mount_graph(root, type_relationships = "all", all_relationships = false)
        relationships = get_relationships(type_relationships)

        @root = root
        populate_network relationships, all_relationships
      end

      protected
      
      # Get relationships in database from labels passed
      # ====== Params:
      # +type_relationships+:: +Array+ labels to find relationships, can be multiple in array or just one in a simple String
      # Returns Relationships found
      def get_relationships type_relationships
        return SocialFramework::Relationship.all if type_relationships == "all"

        if type_relationships.class == String
          return SocialFramework::Relationship.where label: type_relationships
        elsif type_relationships.class == Array
          result = []
          type_relationships.each do |relationship|
            relationship = SocialFramework::Relationship.find_by_label relationship.to_s
            result.push(relationship) unless relationship.nil?
          end

          return result
        end
      end

      # Select all user's edges with the relationships required
      # ====== Params:
      # +user_id+:: +User+ to find to get edges
      # +relationships+:: +Array+ relationships required to select edges
      # +all_relationships+:: +Boolean+ represents type selection, if is false select the edges thats have any relationship required, if true select just edges thats have all relationships required
      # Returns Edges selected
      def get_edges user_id, relationships, all_relationships
        begin
          user = SocialFramework::User.find user_id
        rescue
          return []
        end

        user.edges.select do |e|
          id = (e.origin.id == user.id) ? e.destiny.id : e.origin.id

          network_include_vertex = @network.include? Vertex.new(id)
          get_any_relationship = (not (e.relationships & relationships).empty? and not all_relationships)
          get_all_relationship = ((e.relationships & relationships).count == relationships.count and all_relationships)

          not network_include_vertex and (get_any_relationship or get_all_relationship)
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
      # +all_relationships+:: +Boolean+ represents type selection, if is false select the edges thats have any relationship required, if true select just edges thats have all relationships required
      # Returns Array network
      def populate_network relationships, all_relationships
        @queue = Array.new
        @queue << {vertex: Vertex.new(@root.id), depth: 1}

        until @queue.empty?
          pair = @queue.shift
          current_vertex = pair[:vertex]
          @network << current_vertex

          next if pair[:depth] == @depth
          new_depth = pair[:depth] + 1

          edges = get_edges(current_vertex.id, relationships, all_relationships)

          edges.each do |e|
            user = (e.origin.id == current_vertex.id) ? e.destiny : e.origin

            pair = @queue.select { |p| p[:vertex].id == user.id }.first
            new_vertex = pair.nil? ? Vertex.new(user.id) : pair[:vertex]
            
            current_vertex.add_edge new_vertex
            new_vertex.add_edge current_vertex if e.bidirectional

            if pair.nil? and not @network.include? new_vertex
              @queue << {vertex: new_vertex, depth: new_depth}
            end
          end
        end
      end
    end

    # Represent graph's vertex
    class Vertex
      attr_accessor :id, :edges

      # Constructor to vertex 
      # ====== Params:
      # +id+:: +Integer+ user id
      # Returns Vertex's Instance
      def initialize id = 0
        @id = id
        @edges = Array.new
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
      # Returns Edges with the new addition
      def add_edge destiny
        edge = Edge.new self, destiny
        @edges << edge
      end

      def to_s
        "vertex #{id}"
      end
    end
    
    # Represent the conneciont edges between vertices
    class Edge
      attr_accessor :origin, :destiny
      
      # Constructor to Edge 
      # ====== Params:
      # +origin+:: +Vertex+ relationship origin
      # +destiny+:: +Vertex+ relationship destiny
      # Returns Vertex's Instance
      def initialize origin, destiny
        @origin = origin
        @destiny = destiny
      end

      def to_s
        "#{@origin.id} -> #{@destiny.id}"
      end
    end
  end
end
