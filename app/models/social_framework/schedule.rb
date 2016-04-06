module SocialFramework
  class Schedule < ActiveRecord::Base
  	belongs_to :user
  	has_many :participant_events
  	has_many :events, through: :participant_events
  end
end
