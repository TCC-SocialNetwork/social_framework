FactoryGirl.define do
  factory :user, class: SocialFramework::User do
    username "user"
    email "user@email.com"
    password "password"
  end

  factory :user2, class: SocialFramework::User do
    username "user2"
    email "user2@email.com"
    password "password"
  end

  factory :user3, class: SocialFramework::User do
    username "user3"
    email "user3@email.com"
    password "password"
  end

  factory :edge, class: SocialFramework::Edge do
    origin nil
    destiny nil
  end

  factory :event, class: SocialFramework::Event do
    title "Title 1"
    start DateTime.new(2016, 01, 01, 10, 0, 0)
    finish DateTime.new(2016, 01, 01, 11, 0, 0)
  end

  # Brasilia's downtown, Brazil
  factory :origin, class: SocialFramework::Location do
    latitude -15.793538
    longitude -47.884819
  end

  # TV Tower - Brasilia, Brazil
  factory :destiny, class: SocialFramework::Location do
    latitude -15.790689
    longitude -47.892941
  end
end