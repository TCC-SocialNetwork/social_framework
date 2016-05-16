module SocialFramework
  class Route < ActiveRecord::Base
  	belongs_to :user
  	has_many :locations
  end
end
