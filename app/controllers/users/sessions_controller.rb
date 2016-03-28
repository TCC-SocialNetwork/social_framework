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
    graph.mount_graph(current_user)
  end

  # DELETE /resource/sign_out
  # def destroy
  #   super
  # end

  # protected

  # New params added: login and username. If you have extra params to permit, append them to the sanitizer.
  def configure_sign_in_params
    devise_parameter_sanitizer.for(:sign_in) << [:login, :username]
  end
end
