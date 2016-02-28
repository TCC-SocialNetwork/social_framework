module SocialFramework
  class Edge < ActiveRecord::Base
  	include EdgeValidatorHelper
  	# Call validate to verify if edge already exist
  	validate :destiny_must_be_unique_to_same_origin

    belongs_to :origin, class_name: "SocialFramework::User", foreign_key: "origin_id"
    belongs_to :destiny, class_name: "SocialFramework::User", foreign_key: "destiny_id"

    has_many :edge_relationships, class_name: "SocialFramework::EdgeRelationship"
    has_many :relationships, class_name: "SocialFramework::Relationship", through: :edge_relationships
  end
end
