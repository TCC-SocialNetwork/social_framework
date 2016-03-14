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
end