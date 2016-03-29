SocialFramework::Engine.routes.draw do
  devise_for :users, class_name: "SocialFramework::User",
    controllers: {
      sessions: 'users/sessions',
      registrations: 'users/registrations',
      passwords: 'users/passwords'
    }
end
