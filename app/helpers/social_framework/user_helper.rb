module SocialFramework
  # Helper methods to user
  module UserHelper
    # Delete relationship beteween users
    # ====== Params:
    # +user_origin+:: +User+ relationship origin
    # +user_destiny+:: +User+ relationship destiny
    # +label+:: +String+ relationship type
    # Returns Edge of relationship between the users
    def self.delete_relationship(user_origin, user_destiny, label)
      return if user_origin.nil? or user_destiny.nil? or user_destiny == user_origin

      edge = Edge.where(origin: user_origin, destiny: user_destiny).first
      unless edge.nil?
        edge.relationships.each { |r| edge.relationships.destroy(r.id) if r.label == label }
        user_origin.edges.destroy(edge.id) if edge.relationships.empty?
      end
    end
  end
end
