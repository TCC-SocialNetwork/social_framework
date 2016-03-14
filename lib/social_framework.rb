require "social_framework/engine"
require "devise"

# SocialFramework module, connect all elements and use it in correct sequence
module SocialFramework

  # Define the quantity of levels on mount graph to search
  mattr_accessor :depth_to_mount_graph
  @@depth_to_mount_graph = 3
  
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
