module SocialFramework
  class Relationship < ActiveRecord::Base
    has_and_belongs_to_many :edges, class_name: "SocialFramework::Edge"
  end
end
