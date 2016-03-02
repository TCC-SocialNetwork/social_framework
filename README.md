# Social Framework ![License MIT](https://go-shields.herokuapp.com/license-MIT-blue.png)

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

> SocialFramework is divided in three modules, which are: Users, Routes and Schedulers.
In Users module the principal resources to users are providing, like authentication, register, relationships and searchs.
In Routes the Framework provides resources to define routes to users in different situations and provides ways to work this.
And in Schedulers, provides resources to define schedules to users and attempts to relate this schedules.

> Therefore, the SocialFramework can help build Social Networks general or specifics in a way faster and practical and without not worry with recurring problems in this type of system.

----
# Install

> Currently the SocialFramework is not present in RubyGems. To use it you need to clone this repository, below the steps required for installation are presented.

> Clone this repository:

```console
git clone https://github.com/TCC-SocialNetwork/social_framework.git
```

> Adding the following line in your Gemfile:

```ruby
gem 'social_framework', path: 'path/to/social_framework'
```

> The path is the locale of clone done.
After adding gem in your Gemfile intall it:

```console
bundle install
```

> This will be add the SocialFramework to your app.

----
# Getting started

> The SocialFramework uses devise to provides the users's authentication, for a complete documentation to devise see: https://github.com/plataformatec/devise.
The User class already is implemented in SocialFramework and some changes have been applied, like adding username attribute and the behaviors to relatinships betweens users.
The controllers and views of the devise also has been changed to add new updates.

> Initially, some files should be add to app. These files represent the settings to devise with a initializer, the routes and the views registrations and sessions to create and authenticate users.
To this you should execute:

```console
rails generate social_framework:install_devise
```

> This command will create file "config/initializers/devise.rb" containing devise configurations, add routes "devise_for" to map devise controllers and the views in "app/views".
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
# Authors

* Jefferson Nunes de Sousa Xavier
 * jeffersonx.xavier@gmail.com
* Álex Silva Mesquita
 * alex.mesquita0608@gmail.com
