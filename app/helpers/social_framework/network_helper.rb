module SocialFramework
  # Module to construct Social Network
  module NetworkHelper

    # Represent the network on a Graph, with Vertices and Edges
    class Graph
      attr_accessor :network

      # Init the network in Array
      def initializer
        @network = Array.new
      end

      # Mount a graph from an user
      # +root+:: +User+ Root user to mount graph
      # +type_relationships+:: +Array+ labels to find relationships, can be multiple in array or just one in a simple String, default is "all" thats represents all relationships existing
      # +all_relationships+:: +Boolean+ represents type selection to get edges, if is false select the edges thats have any relationship required, if true select just edges thats have all relationships required, default is false
      # +depth+:: +Integer+ depth graph to mounted, default is value defined to 'depth_to_mount_graph' in initializer social_framework.rb
      # Returns The graph mounted
      def mount_graph(root, type_relationships = "all", all_relationships = false,
        depth = SocialFramework.depth_to_mount_graph)

        relationships = get_relationships(type_relationships)
        get_edges(root.edges, relationships, connector)
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
    end
  end
end
