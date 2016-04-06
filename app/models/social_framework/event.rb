module SocialFramework
  class Event < ActiveRecord::Base
  	has_many :participant_events
  	has_many :schedules, through: :participant_events
  end
end
