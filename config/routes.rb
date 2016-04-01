SocialFramework::Engine.routes.draw do
	if /[\w]+$/.match(Dir.pwd).to_s == "social_framework"
	  devise_for :users, class_name: "SocialFramework::User",
	    controllers: {
	      sessions: 'users/sessions',
	      registrations: 'users/registrations',
	      passwords: 'users/passwords'
	    }
	end
end
