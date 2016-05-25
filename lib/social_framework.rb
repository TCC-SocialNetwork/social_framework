require "social_framework/engine"
require "devise"

# SocialFramework module, connect all elements and use it in correct sequence
module SocialFramework
  extend ActiveSupport::Concern

  # Define the quantity of levels on mount graph to search
  mattr_accessor :depth_to_build
  @@depth_to_build = 3

  # Define the quantity of users to search returns
  mattr_accessor :elements_number_to_search
  @@elements_number_to_search = 5
  
  # Type relationships to suggest a new relationships,
  # can be an string or array with multiple relationships
  # value default is "friend", the value "all" represent all reslationships type
  mattr_accessor :relationship_type_to_suggest
  @@relationship_type_to_suggest = "friend"
  
  # Quantity of relationships to suggest a new relationship
  mattr_accessor :amount_relationship_to_suggest
  @@amount_relationship_to_suggest = 5

  # Type relationships to consider to invite to events,
  # can be an string or array with multiple relationships
  # value default is "all" thats represent all relationships type
  mattr_accessor :relationship_type_to_invite
  @@relationship_type_to_invite = "all"

  # Define Roles to Events and permissions to each role
  mattr_accessor :event_permissions
  @@event_permissions = { creator: [:remove_event, :remove_admin, :remove_inviter, :remove_participant,
                                    :invite, :make_admin, :make_inviter, :make_creator,
                                    :add_route, :remove_route],
                          admin: [:remove_inviter, :remove_admin, :remove_participant,
                                  :invite, :make_admin, :make_inviter,
                                  :add_route, :remove_route],
                          inviter: [:remove_participant, :invite],
                          participant: []
                        }

  # Used to define slots duration to mount schuedule graph, default is 1.hour
  mattr_accessor :slots_size
  @@slots_size = 1.hour

  # Max size to duration to mount schedule graph
  mattr_accessor :max_duration_to_schedule_graph
  @@max_duration_to_schedule_graph = 1.month

  # Max weight to consider in schedule build
  mattr_accessor :max_weight_schedule
  @@max_weight_schedule = 10

  # Represent the principal mode of travel and maximum deviation accepted
  mattr_accessor :principal_deviation
  @@principal_deviation = {mode: "driving", deviation: 5000}

  # Represent the secondary mode of travel and maximum deviation accepted
  mattr_accessor :secondary_deviation
  @@secondary_deviation = {mode: "walking", deviation: 500}

  # Used to change variables in configuration
  # Retuns a block to self
  def self.setup
    yield self
  end
end
