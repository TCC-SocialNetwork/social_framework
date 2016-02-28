module SocialFramework
  # Associative class to relationship beteween Edge and Relationship classes
  class EdgeRelationship < ActiveRecord::Base
    belongs_to :edge, class_name: "SocialFramework::Edge"
    belongs_to :relationship, class_name: "SocialFramework::Relationship"
  end
end
