module SocialFramework
  class Route < ActiveRecord::Base
  	has_and_belongs_to_many :users
  	has_many :events
  	has_many :locations
  end
end
