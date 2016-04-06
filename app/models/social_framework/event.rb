module SocialFramework
  class Event < ActiveRecord::Base
  	has_many :participant_events
  	has_many :schedules, through: :participant_events
  	
  	# belongs_to :creator, class_name: "SocialFramework::User", foreing_key: "creator_id"
  	# has_many :participants, class_name: "SocialFramework::User"
  end
end
