module SocialFramework
  module UserHelper
    private
      # Create relationship beteween users
    # ====== Params:
    # +user_origin+:: +User+ relationship origin
    # +user_destiny+:: +User+ relationship destiny
    # +label+:: +String+ relationship type
    # +active+:: +Boolean+ define relationship like active or inactive
    # Returns Relationship type or a new edge relationship
    def self.create_relationship(user_origin, user_destiny, label, active=true)
      return if user_origin.nil? or user_destiny.nil? or user_destiny == user_origin
      
      edge = Edge.find_or_create_by(origin: user_origin, destiny: user_destiny)
      relationship = Relationship.find_or_create_by(label: label)
      unless edge.relationships.include? relationship
        EdgeRelationship.create(edge: edge, relationship: relationship, active: active)
      end
    end
  end
end
