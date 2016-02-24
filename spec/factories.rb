FactoryGirl.define do
  factory :user, class: SocialFramework::User do
    username "user"
    email "user@email.com"
    password "password"
  end
end