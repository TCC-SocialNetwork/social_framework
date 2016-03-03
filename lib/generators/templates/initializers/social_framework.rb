# Use this to configure graph attribues for mounting, searchs and suggestions
SocialFramework.setup do |config|
  
  # Define the quantity of relationships to suggest new uniderictional relationships  
  # config.amount_of_relationships = 5

  # Define the quantity of relationships to suggest new bidirectional relationships
  # config.amount_of_bidirectional_relationships = 5

  # Define the quantity of levels on mount graph to search
  # config.depth_to_mount_graph = 3

  # Type relationships to suggest new bidirectional relationships
  # config.relationship_type_to_bidirectional_suggest = "friend"

  # Type relationships to suggest new unidirectional relationships
  # config.relationship_type_to_unidirectional_suggest = "follow"

end
