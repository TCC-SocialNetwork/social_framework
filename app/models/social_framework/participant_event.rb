module SocialFramework
  class ParticipantEvent < ActiveRecord::Base
    belongs_to :event
    belongs_to :schedule
  end
end
