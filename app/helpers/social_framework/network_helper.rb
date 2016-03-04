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

        add_vertex root
        populate_network root, relationships, all_relationships, 1
      end

      private
      
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
      # +edges+:: +Array+ all user's edges
      # +relationships+:: +Array+ relationships required to select edges
      # +all_relationships+:: +Boolean+ represents type selection, if is false select the edges thats have any relationship required, if true select just edges thats have all relationships required
      # Returns Edges selected
      def get_edges edges, relationships, all_relationships
        edges.select do |e|
          (not (e.relationships & relationships).empty? and not all_relationships) or
            ((e.relationships & relationships).count == relationships.count and all_relationships)
        end
      end

      # Create a new vertex with user id and add in @network
      # ====== Params:
      # +user+:: +User+ to get id
      # Returns Array network
      def add_vertex user
        return if user.nil? or user.id.nil? or @network.any? {|v| v.id == user.id}
        vertex = Vertex.new user.id
        @network << vertex 
      end

      # Populate network with the users related 
      # ====== Params:
      # +root+:: current +User+ to add
      # +relationships+:: +Array+ relationships required to select edges
      # +all_relationships+:: +Boolean+ represents type selection, if is false select the edges thats have any relationship required, if true select just edges thats have all relationships required
      # +current_depth+:: +Integer+ represents depth walked
      # Returns Array network
      def populate_network root, relationships, all_relationships, current_depth
        return if current_depth > @depth
        edges = get_edges(root.edges, relationships, all_relationships)

        edges.each do |e|
          user = e.origin unless e.origin == root
          user = e.destiny unless e.destiny == root
          add_vertex user
          populate_network user, relationships, all_relationships, current_depth + 1
        end
      end
    end

    # Represent graph's vertex
    class Vertex
      attr_accessor :id

      # Constructor to vertex 
      # ====== Params:
      # +id+:: +Integer+ user id
      # Returns Vertex's Instace
      def initialize id
        @id = id
      end
    end
  end
end
