# Use this to configure graph attribues for mounting, searchs and suggestions
SocialFramework.setup do |config|
  
  # Define the quantity of levels on mount graph to search
  # config.depth_to_build = 3

  # Define the quantity of users to search returns
  # config.users_number_to_search = 5

  # Type relationships to suggest a new relationships,
  # can be an string or array with multiple relationships
  # value default is "friend", the value "all" represent all reslationships type
  # config.relationship_type_to_suggest = "friend"
  
  # Quantity of relationships to suggest a new relationship
  # config.amount_relationship_to_suggest = 5

  # Type relationships to consider to invite to events,
  # can be an string or array with multiple relationships
  # value default is "all" thats represent all relationships type
  # config.relationship_type_to_invite = "all"

  # Define Roles to Events and permissions to each role
  # config.event_permissions = { creator: [:remove_event, :invite, :uninvite, :make_admin, :make_inviter, :make_creator],
                         #   admin: [:invite, :uninvite, :make_admin, :make_inviter],
                         #   recruiter: [:invite, :uninvite],
                         #   participant: []
                         # }


end
