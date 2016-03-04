require "social_framework/engine"
require "devise"

# SocialFramework module, connect all elements and use it in correct sequence
module SocialFramework

  # Define the quantity of relationships to suggest new uniderictional relationships
  mattr_accessor :amount_of_relationships
  @@amount_of_relationships = 5
  
  # Define the quantity of relationships to suggest new bidirectional relationships
  mattr_accessor :amount_of_bidirectional_relationships
  @@amount_of_bidirectional_relationships = 5

  # Define the quantity of levels on mount graph to search
  mattr_accessor :depth_to_mount_graph
  @@depth_to_mount_graph = 3
  
  # Type relationships to suggest new bidirectional relationships
  mattr_accessor :relationship_type_to_bidirectional_suggest
  @@relationship_type_to_bidirectional_suggest = "friend"
  
  # Type relationships to suggest new unidirectional relationships
  mattr_accessor :relationship_type_to_unidirectional_suggest
  @@relationship_type_to_unidirectional_suggest = "follow"

  # Used to change variables in configuration
  # Retuns a block to self
  def self.setup
    yield self
  end
end
