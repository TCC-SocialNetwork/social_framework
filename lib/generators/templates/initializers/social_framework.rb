# Use this to configure graph attribues for mounting, searchs and suggestions
SocialFramework.setup do |config|
  
  # Define the quantity of levels on mount graph to search
  # config.depth_to_build = 3

  # Define the quantity of users to search returns
  # config.elements_number_to_search = 5

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
  # config.event_permissions = { creator: [:remove_event, :remove_admin, :remove_inviter, :remove_participant,
                            #             :invite, :make_admin, :make_inviter, :make_creator,
                            #             :add_route, :remove_route],
                            #   admin: [:remove_inviter, :remove_admin, :remove_participant,
                            #           :invite, :make_admin, :make_inviter,
                            #           :add_route, :remove_route],
                            #   inviter: [:remove_participant, :invite],
                            #   participant: []
                            # }

  # Used to define slots duration to mount schuedule graph, default is 1.hour
  # config.slots_size = 1.hour

  # Max size to duration to mount schedule graph
  # config.max_duration_to_schedule_graph = 1.month

  # Max weight to consider in schedule build
  # config.max_weight_schedule = 10

  # Represent the principal mode of travel and maximum deviation accepted
  # config.principal_deviation = {mode: "driving", deviation: 5000}

  # Represent the secondary mode of travel and maximum deviation accepted
  # config.secondary_deviation = {mode: "walking", deviation: 500}
end
