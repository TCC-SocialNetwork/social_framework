module SocialFramework
  class Edge < ActiveRecord::Base
    belongs_to :origin, class_name: "SocialFramework::User", foreign_key: "origin_id"
    belongs_to :destiny, class_name: "SocialFramework::User", foreign_key: "destiny_id"

    has_and_belongs_to_many :relationships, class_name: "SocialFramework::Relationship"
  end
end
