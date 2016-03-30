# Controller responsible to sign_in an sign_out users
class Users::SessionsController < Devise::SessionsController
  include SocialFramework
  before_filter :configure_sign_in_params, only: [:create]

  # GET /resource/sign_in
  # def new
  #   super
  # end

  # POST /resource/sign_in
  def create
    super
    current_user.graph.build(current_user, [:username, :email]) if current_user
  end

  # DELETE /resource/sign_out
  def destroy
    current_user.graph.destroy(current_user.id) if current_user
    super
  end

  # protected

  # New params added: login and username. If you have extra params to permit, append them to the sanitizer.
  def configure_sign_in_params
    devise_parameter_sanitizer.for(:sign_in) << [:login, :username]
  end
end
