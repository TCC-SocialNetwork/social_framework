module SocialFramework
  class Location < ActiveRecord::Base
  	belongs_to :route
  end
end
