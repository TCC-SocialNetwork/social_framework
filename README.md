# SocialFramework ![License MIT](https://go-shields.herokuapp.com/license-MIT-blue.png)

----
[![Gem Version](https://badge.fury.io/rb/social_framework.svg)](https://badge.fury.io/rb/social_framework)
[![Build Status](https://travis-ci.org/TCC-SocialNetwork/social_framework.svg)](https://travis-ci.org/TCC-SocialNetwork/social_framework)
[![Code Climate](https://codeclimate.com/github/TCC-SocialNetwork/social_framework/badges/gpa.svg)](https://codeclimate.com/github/TCC-SocialNetwork/social_framework)
[![Test Coverage](https://codeclimate.com/github/TCC-SocialNetwork/social_framework/badges/coverage.svg)](https://codeclimate.com/github/TCC-SocialNetwork/social_framework/coverage)
[![Inline docs](http://inch-ci.org/github/TCC-SocialNetwork/social_framework.svg)](http://inch-ci.org/github/TCC-SocialNetwork/social_framework)
[![Stories in Ready](https://badge.waffle.io/TCC-SocialNetwork/social_framework.png?label=ready&title=Ready)](http://waffle.io/TCC-SocialNetwork/social_framework)
[![Stories in Progress](https://badge.waffle.io/TCC-SocialNetwork/social_framework.png?label=in%20progress&title=In%20Progress)](http://waffle.io/TCC-SocialNetwork/social_framework)

----
# What is SocialFramework?

> The SocialFramework is a Rails Engine that helps developers build Social Networks providing common and specific resources to this.

> SocialFramework is divided into three modules, which are: Users, Routes and Schedulers.
In Users module the principal resources to users are provided, like authentication, register, relationships and searchs.
In Routes the Framework provides resources to define routes to users in different situations and provides ways to work this.
And in Schedulers, provides resources to define schedules to users and attempts to relate this schedules.

> Therefore, the SocialFramework can help build general or specifics social networks in a way faster and practical and without not worry with recurring problems in this type of system.

----
# Install

> Adding the following line in your Gemfile:

```ruby
gem 'social_framework'
```

> The path described above should be changed to the path you did the clone.
After adding gem in your Gemfile, intall it with the command:

```console
bundle install
```

> This will add the SocialFramework to your app.

----
# Getting started

> The SocialFramework is based on Devise, which is a flexible authentication solution for Rails. For a full documentation to Devise see: https://github.com/plataformatec/devise.
The User class already is implemented in SocialFramework and some changes have been applied, like adding username attribute and the behaviors to relationships betweens users.
The controllers and views of the Devise also has been changed to add new features.

> Initially, some files should be added to app. These files represent the settings to SocialFramework and Devise with initializers, the i18n file to Devise, the routes and the views registrations and sessions to create and authenticate users.
To this you should execute:

```console
rails generate social_framework:install
```

> This command will create file "config/initializers/devise.rb" containing Devise configurations, the file "config/initializers/social_framework.rb" with SocialFramework configurations, the i18n file to Devise, add routes "devise_for" to map Devise controllers and the views in "app/views".
With this your app is prepared to use users module with configurations and behaviors defaults.

> To test your app remember execute migrations:

```console
rake db:create
rake db:migrate
```

> All framework tables will be created in app database.

> To authentication page access "/users/sign_in" route, this page is prepared to authenticate users with email or username.
To create user page access "/users/sign_up" route, creating a new user you will be automatically connected.

> When you use the Devise Mailer like the Confirmable Module it's necessary add in your environment the configs to action mailer, for example, if you are in development environment you should add the following in 'development.rb' file.

```ruby
config.action_mailer.default_url_options = { host: 'localhost', port: 3000 }

config.action_mailer.delivery_method = :smtp

config.action_mailer.smtp_settings = {
  address: "smtp.gmail.com",
  port: 587,
  domain: ENV["GMAIL_DOMAIN"],
  authentication: "plain",
  enable_starttls_auto: true,
  user_name: ENV["GMAIL_USERNAME"],
  password: ENV["GMAIL_PASSWORD"]
}
```

> You can change the values in 'domain', 'user_name' and 'password' or create the local environment variables, this is indicated to hide that informations and ensure greater security.
The same configurations is valid to test and production environments, in files 'test.rb' and 'production.rb'.

----
# Controllers filters and helpers

> Devise provides some elements to use in your controllers and views. To set up a controller with user authentication, just add this before_action (This works because the SocialFramework already contains User class):

```ruby
before_action :authenticate_user!
```

> Other elements are:

```ruby
user_signed_in?
```

> To verify if user is signed in.

```ruby
current_user
```

> To get current signed-in user.

```ruby
user_session
```

> To access the session for this scope.

> After signing in a user, confirming the account or updating the password, Devise will look for a scoped root path to redirect to. You can change this overriding the methods `after_sign_in_path_for` and `after_sign_out_path_for`.

----
# Configuring Models

> The User class in SocialFramework implements default modules from Devise. See Devise documentation to know all Devise modules and your features.

> Beyond Devise, the User class has methods that implements the behaviors to users relationships.
You can override any behavior extending the class in other model, like:

```ruby
class OtherUserClass < SocialFramework::User
  # Your code goes here
end
```

> It's necessary change the class name in file 'routes.rb' to the new class created to devise can see this class. To do this:

```ruby
devise_for :users, class_name: 'OtherUserClass',
    controllers: {sessions: 'users/sessions',
                  registrations: 'users/registrations',
                  passwords: 'users/passwords'}
```

----
## Configuring Migrations

> The User class provides the default attributes username, email and password.
To add or remove attributes to this or any other class you can add the Migrate in yor app.
The SocialFramework provides a generator to do this, in this case you just need execute:

```console
rails generate social_framework:install_migrations -m users
```

> The User migrate will be added in your app and you can change it according your needs.
The '-m' parameter is used generate specific migrations, expect the migrations names. If not exist all migrations will be generated.

> Case you add or remove attributes to User you must notify Devise, using a simple before filter in your ApplicationController:

```ruby
class ApplicationController < ActionController::Base
  before_action :configure_permitted_parameters, if: :devise_controller?

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.for(:sign_up) << :new_attribute
    devise_parameter_sanitizer.for(:account_update) << :new_attribute
  end
end
```

> This make that sign_up and account_update receives the new attribute. You can use remove method to remove attributes existing.
It's equals to others actions, like sign_in.

----
# Configuring Controllers

> All Devise controllers can be extended and have your overridden methods:

```ruby
class OtherRegistrationControllerClass < Users::RegistrationsController
  # Your code goes here
end
```

> Other controllers are: confirmations, omniauth_callbacks, passwords, sessions and unlocks.
To use omniauth_callbacks, unlocks and confirmations it's necessary add Devise modules matching.
All Devise controllers in SocialFramework have prefix Users.

----
## Configuring Routes

> When you override some Devise controller you must be define that new controller in your routes.
This can be done changing path to controller in deviser_for, like this:

```ruby
devise_for :users, class_name: 'SocialFramework::User',
  controllers: {sessions: 'users/sessions',
                registrations: 'new_registration_controller_path',
                passwords: 'users/passwords'}
```

> To registrations controller was replaced with a new controller and that controller was added in routes.

----
# Configuring Views

> To add Devise's views in your app the SocialFramework provides a generator thats should be run like this:

```console
rails generate social_framework:views
```

> This command will add all views to your app.

> To add specific views you can use '-v' parameter and pass the views names, like this:

```console
rails generate social_framework:views -v registrations sessions passwords
```

> This command will add views registrations, sessions and passwords to your app.
The other views are: confirmations, mailer and unlocks.
Initially the SocialFramework add views registrations and sessions to your app providing authentication and register to users.

----
# SocialFramework's Modules

> Currently the SocialFramework has one module to Users and Relationships, this module provides authentication, resgistrations, relationships between users and searchs in network mounted.

----
## Users Module

> This module provides the principal logic to social networks, like create, confirm and remove relationships between users, beyond searchs, registers, updates and athentications.

> The relationships structure was built with a many to many association between Users through Edges. The Edges has user origin, user destiny, status can be active or inactive, if is bidirectional or not to specify relationships like two-way or one-way and label with the relationship name.
May be exists multiple relationships between the same users. Each relationship is represent with an Edge.

> To create a new relationship between two users it's used the method 'create_relationship' defined in User Class. The following is the method signature.

```ruby
create_relationship(destiny, label, bidirectional=true, active=false)
```

> The user asking for relationship should invoke this method passing the destiny user and label to relationship. For default is created a bidirectional  and inactive relationship between this users. It's possible change this passing the other params.

> To active this relationship created it's necessary confirm. To do this the destiny user should invoke the method 'confirm_relationship'. The following is the method signature.

```ruby
confirm_relationship(user, label)
```

> It's necessary pass the origin user and label with type to relationship. The origin user can't confirm this relationship.

> To remove some relationship the users should invoke the method 'remove_relationship', passing the other user in relationship and label. The following is the method signature.

```ruby
remove_relationship(destiny, label)
```

> The User class provide also a method to get users relations with an user, to this invoke the following method:

```ruby
relationships(label, status = true, created_by = "any")
```

> The label represent the type relationships to get, 'status' is used to get active or inactive relationships, the default is true, 'created_by' is used to specify relationships to get, can be any to get any relationship, self to get relationships with origin is equals self or other to get relationships when destiny is equals self.

> The Users Module uses a Graph to provide some functionalities, like searchs in network and relationships suggestion. All this functionalities are presents in 'NetworkHelper' thats implements the classes Graph, Vertex and Edge.
The Graph can be accessed from the method 'graph' present in User class.
In sign_in action the Graph is built with the User logged like root. The Graph is built until the depth specified in initializer 'social_framework.rb' in variable 'depth_to_build', the value default is three. The following is the method signature to build graph.

```ruby
build(root, attributes = [:username, :email], relationships = "all")
```

> The attributes are user attributes thats will be mapped to vertices, for default contains 'username' and 'email', the attribute 'id' already is passed mandatorily. Relationships are the type of relationships to build the Graph, should be a string or an array, "all" is to build Graph with any relationships. In sign_in action the Graph is built with attributes 'username' and 'email', beyond 'id'.

> With the Graph built it's possible suggest relationships. To this it's analyzed the third level in graph finding common relationships with type specified in initializer 'social_framework.rb' in variable 'relationship_type_to_suggest', the value default is 'friend', the variable 'amount_relationship_to_suggest' specifies the value to use to suggest relationships, the default value is five. The following is the method signature.

```ruby
suggest_relationships(type_relationships = SocialFramework.relationship_type_to_suggest,
  amount_relationships = SocialFramework.amount_relationship_to_suggest)
```

> Considering the default values, if an user 'A' and an user 'C' has five relationships with type 'friend' with other five users the system  suggest to the user 'A' start the same relationship with the user 'C'.

> The search in Graph is executed using the [BFS](https://en.wikipedia.org/wiki/Breadth-first_search) algorithm. The following is the method signature to search.

```ruby
search(map, search_in_progress = false, elements_number = SocialFramework.elements_number_to_search)
```

> It's passed a map to be used in search, this map represent keys and values to compare vertices, for example, the map '{username: 'user', email: 'user'}' will cause an search with any vertice thats contains the string 'user' in username or email.
The param 'search_in_progress' is used to continue a search finding more results, to do this pass true. And, the param 'elements_number' define the quantity of users to return, this value is specified in initializer 'social_framework.rb' in variable 'elements_number_to_search', the value default is five.

> An example to continue searchs is shown below. For default, when you continue a search the 'elements_number' param is used to increase the maximum size to results found.
In this case the first call returns the first five users found in graph, the second call returns more ten users and the final array has size fifteen.

```ruby
map = {username: 'user', email: 'user'}
graph.search(map)
graph.search(map, true, 10)
```

> You can change the default behavior to continue searchs passing a block to method, this block will indicate how the 'elements_number' must be increased. For example:

```ruby
map = {username: 'user', email: 'user'}
graph.search(map, false, 1)
graph.search(map, true) { |elements_number| elements_number *= 2 }
```

> In that case the 'elements_number' will double every call search method with this block. Therefore, the first call returns one user due to the value passed, the second two, the third four, and so on.

> When the search reaches the end of the Graph and not yet found all required users an search in database is done to complete the array.

----
## Schedules Module

> This module provides the logic to work with the schedule of social network users, how to create, enter, invite, confirm, exit and remove events.

> The struct of relationships was built as follow: An Schedule belongs to a user and have a many to many association with Event through a Participant_Event, which has a confirmed attribute indicating whether the user has confirmed the event or is pending. Beyond an event be able to be present in various schedules, an event have a title, a description, a date and start time, a date and finish time, can or can not have an associated route and if the evente is particular an another user will only be able participate in the event if it is invited, if not particular any user can enter the event.

> To create a new event uses the method 'create_event', defined in Schedule Class. The following is the method signature.

```ruby
create_event(title, start, duration = nil, description = "", particular = false)
```

> If not passed the duration of the event, its description or if is particular this will have its finish as the end of the day the event occurs, its description will be set to an empty string and the event is not particular. These options can be changed passing the respectives parameteres in the method call. For the event be created the user can not have events in your schedule that match with the event time which he wants to create.

> To an user enter in an event should use the method 'enter_in_event', defined in Schedule Class. The following is the method signature.


```ruby
enter_in_event(event)
```

> It is necessary to pass as a parameter the event that the user wants to enter. So that to the user can enter in event, he can not have events on your schedule that match with the event time which he wants to enter.

> To an user can confirm an invite to enter in an event should use the method 'confirm_event', defined in Schedule Class. The following is the method signature.

```ruby
confirm_event(event)
```
> It is necessary to pass as a parameter the event that the user wants to confirm. So that to the user can enter in event, he can not have events on your schedule that match with the event time wich he wants to confirm.

> To exit an event should invoke the method 'exit_event', defined in Schedule Class. The following is the method signature.

```ruby
exit_event(event)
```

> It is necessary to pass as a parameter the event that the user wants to remove from his schedule. But to get out of the event the user can not have the role of 'creator' of the event, if it is the creator of this event must pass the role to another user before leaving the event.

> To remove an event should invoke the method 'remove_event', defined in Schedule Class. The following is the method signature.

```ruby
remove_event(event)
```

> It is necessary to pass as a parameter the event that the user wants to remove. But to delete the event the user can have the role of 'creator' of the event.

> To check if an user has events in a defined time interval you can use the method 'events_in_period', defined in Schedule Class. This method return all events that are within the time interval. The following is the method signature.

```ruby
events_in_period(start, finish = start.end_of_day)
```

> If not passed the finish of the period as a parameter, this will have its finish as the end of the start day.

> To invite an user to an event should invoke the method 'invite', defined in Schedule Class. The following is the method signature.

```ruby
invite(inviting, guest, relationship = SocialFramework.relationship_type_to_invite)
```

> It is necessary to pass as a parameter the user inviting and the user guest, if not passed the type of the relationship between the users will be used the type defined in the configuration file. To invite an user to an event the inviting should be confirmed in event, have the permition to 'invite' and have the guest into your circle of relationships with the specificed type of relationship, should use the type 'all' to any type of relationship.

> To change the role of a participant in an event should invoke the method 'change_participant_role', defined in Schedule Class. The following is the method signature.

```ruby
change_participant_role(maker, participant, action)
```

> It is necessary to pass as a parameter the maker will change the role, the participant will have his role changed and the action that the maker will execute, this action should be prefixed 'maker' or 'remove', which indicates whether it is assigned or removed a role respectively, followed by a '_' and the role of action, for example: ':make_admin'. To the changing role be successfully changed the maker must have permission to execute the action. If the action is ':make_creator' the make will receive the paper of 'admin', because should only be an user creator of event.

> To remove a participant of an event should invoke the method 'remove_participant', defined in Schedule Class. The following is the method signature.

```ruby
remove_participant(remover, participant)
```

> It is necessary to pass as a parameter the remover will remove an user and the participant will be removed from the event. To the removal is performed successfully the remover must have permission to execute the action.

> To add a route in an event should invoke the method 'add_route', defined in Schedule Class. The following is the method signature.

```ruby
add_route(user, route)
```

> It is necessary to pass as a parameter the user will add a route in an event and the route will be added. To the addition is performed successfully the user must have permission to ':add_route'.

> The Schedules Module uses a graph to provide slotes time ordered considering the greater amount of weight slotes. This functionality is present in the 'ScheduleHelper', which includes the Vertex and Edge classes and implements the Graph class.

> In this graph the vertices with the user type only have connection with the vertices with the slot type, and the vertices with the slote type only have connection with the vertices with the user type, thus forming a bipartite graph.

> To build the graph should invoke the method 'build', defined in Schedule Class. The following is the method signature.

```ruby
build(users, start_day, finish_day, start_hour = Time.parse("00:00"), finish_hour = Time.parse("23:59"), slots_size = SocialFramework.slots_size)
```

> The parameter 'users' are users who have their schedules analyzed to find the best time for a possible event marking. This parameter can be an array, where no user has weight in the event or can be a Hash where the key is the user and the value is the weight of their presence at the event, this weight has its maximum value defined in the configuration file in the variable 'max_weight_schedule' if the user have the weight set to the symbol ': fixed' this user will have their presence as mandatory in the event, and only the slotes that this user has availability will be analyzed.

> The 'start_day' parameter indicates starting from what day the event will be marked, and the 'finish_day' parameter indicates the day limit for marking the event. The parameter 'start_hour' and 'finish_hour' parameter define a time of day that the event may occur, for example you can set the time from 08:00 to 18:00, if not passed as parameter is considered to the event may be scheduled at any time.

> The 'slote_size' parameter indicates the duration of the slotes, if not passed as a parameter is used the standard time, set in the configuration file and with 1 hour.

> The amount of slotes to be added in the graph depends on the time interval to be analyzed and duration of slotes.

> To create edges between users and slotes is checked if the user has availability on his schedule in the time that slote has, if the user has availability for this slote is created an edge between the user and the slote, and the user weight is added to the weight of slote. The method returns the slotes ordered by the greater weight that each has Slote.

----
# Authors

* Álex Silva Mesquita
 * alex.mesquita0608@gmail.com
* Jefferson Nunes de Sousa Xavier
 * jeffersonx.xavier@gmail.com
