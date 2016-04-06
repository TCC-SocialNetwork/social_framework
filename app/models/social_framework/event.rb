module SocialFramework
  class Event < ActiveRecord::Base
  	has_and_belongs_to_many :schedules
  	# belongs_to :creator, class_name: "SocialFramework::User", foreing_key: "creator_id"
  	# has_many :participants, class_name: "SocialFramework::User"
  end
end
