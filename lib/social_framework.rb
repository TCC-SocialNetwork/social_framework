require "social_framework/engine"
require "devise"

# SocialFramework module, connect all elements and use it in correct sequence
module SocialFramework
  extend ActiveSupport::Concern

  # Define the quantity of levels on mount graph to search
  mattr_accessor :depth_to_build
  @@depth_to_build = 3

  # Define the attributes to build vertex in network graph,
  # That attributes must exist in User or Event classes,
  # Are used to search elements in graph
  mattr_accessor :attributes_to_build_graph
  @@attributes_to_build_graph = [:username, :email, :title]

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

  # User class name
  # Use this when extends the default User to use other classes
  mattr_accessor :user_class
  @@user_class = 'SocialFramework::User'

  # Schedule class name
  # Use this when extends the default Schedule to use other classes
  mattr_accessor :schedule_class
  @@schedule_class = 'SocialFramework::Schedule'

  # Event class name
  # Use this when extends the default Event to use other classes
  mattr_accessor :event_class
  @@event_class = 'SocialFramework::Event'

  # Route class name
  # Use this when extends the default Route to use other classes
  mattr_accessor :route_class
  @@route_class = 'SocialFramework::Route'

  # Edge class name
  # Use this when extends the default Edge to use other classes
  mattr_accessor :edge_class
  @@edge_class = 'SocialFramework::Edge'

  # Location class name
  # Use this when extends the default Location to use other classes
  mattr_accessor :location_class
  @@location_class = 'SocialFramework::Location'

  # ParticipantEvent class name
  # Use this when extends the default ParticipantEvent to use other classes
  mattr_accessor :participant_event_class
  @@participant_event_class = 'SocialFramework::ParticipantEvent'

  # Google key to use Google Maps API, you can define a environment variable
  mattr_accessor :google_key
  @@google_key = ' AIzaSyBcMn7Awv_OKT3LWvAHtkwERPNSwkNBqpM '

  # Used to change variables in configuration
  # Retuns a block to self
  def self.setup
    yield self
  end
end
