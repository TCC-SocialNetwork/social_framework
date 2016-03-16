# SocialFramework ![License MIT](https://go-shields.herokuapp.com/license-MIT-blue.png)

----
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

> Currently the SocialFramework is not present in RubyGems. To use it you need to clone this repository, the steps to install it are presented below.

> Clone this repository:

```console
git clone https://github.com/TCC-SocialNetwork/social_framework.git
```

> Adding the following line in your Gemfile:

```ruby
gem 'social_framework', path: 'path/to/social_framework'
```

> The path described above should be changed to the path you did the clone.
After adding gem in your Gemfile, intall it with the command:

```console
bundle install
```

> This will add the SocialFramework to your app.

----
# Getting started

> The SocialFramework is based on Devise, which is a ... that provides the users' authentication, for a full documentation to Devise see: https://github.com/plataformatec/devise.
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

----
## Configuring Migrations

> The User class provides the default attributes username, email and password.
To add or remove attributes to this or any other class you can add the Migrate in yor app.
The SocialFramework provides a generator to do this, in this case you just need execute:

```console
rails generate social_framework:install_migrations -m user
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
## Users' Module

----
# Authors

* Jefferson Nunes de Sousa Xavier
 * jeffersonx.xavier@gmail.com
* Álex Silva Mesquita
 * alex.mesquita0608@gmail.com
