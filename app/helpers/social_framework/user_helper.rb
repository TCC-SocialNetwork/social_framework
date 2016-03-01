module SocialFramework
  # Helper methods to user
  module UserHelper
    # Create relationship beteween users
    # ====== Params:
    # +user_origin+:: +User+ relationship origin
    # +user_destiny+:: +User+ relationship destiny
    # +label+:: +String+ relationship type
    # +active+:: +Boolean+ define relationship like active or inactive
    # +bidirectional+:: +Boolean+ define relationship is bidirectional or not
    # Returns Relationship type or a new edge relationship
    def self.create_relationship(user_origin, user_destiny, label, active=false, bidirectional=true)
      return if user_origin.nil? or user_destiny.nil? or user_destiny == user_origin
      
      edge = Edge.where(["origin_id = :origin_id AND destiny_id = :destiny_id OR 
        destiny_id = :origin_id AND origin_id = :destiny_id",
        { origin_id: user_origin.id, destiny_id: user_destiny.id }]).first

      edge = Edge.create origin: user_origin, destiny: user_destiny, bidirectional: bidirectional if edge.nil?

      relationship = Relationship.find_or_create_by(label: label)
      unless edge.relationships.include? relationship
        EdgeRelationship.create(edge: edge, relationship: relationship, active: active)
      end
    end

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
