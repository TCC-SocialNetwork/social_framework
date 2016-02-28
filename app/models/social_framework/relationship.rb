module SocialFramework
  class Relationship < ActiveRecord::Base
    has_many :edge_relationships, class_name: "SocialFramework::EdgeRelationship"
    has_many :edges, class_name: "SocialFramework::Edge", through: :edge_relationships
  end
end
