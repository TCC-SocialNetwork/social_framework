SocialFramework::Engine.routes.draw do
  devise_for :users, class_name: "SocialFramework::User"
end
