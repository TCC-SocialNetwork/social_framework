require "social_framework/engine"
require "devise"

# SocialFramework module, connect all elements and use it in correct sequence
module SocialFramework
  extend ActiveSupport::Concern

  # Define the quantity of levels on mount graph to search
  mattr_accessor :depth_to_build
  @@depth_to_build = 3

  # Define the quantity of users to search returns
  mattr_accessor :users_number_to_search
  @@users_number_to_search = 5
  
  # Type relationships to suggest a new relationships
  mattr_accessor :relationship_type_to_suggest
  @@relationship_type_to_suggest = "friend"
  
  # Quantity of relationships to suggest a new relationship
  mattr_accessor :amount_relationship_to_suggest
  @@amount_relationship_to_suggest = 5

  # Used to change variables in configuration
  # Retuns a block to self
  def self.setup
    yield self
  end
end
