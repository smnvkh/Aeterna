class Users::RegistrationsController < Devise::RegistrationsController
  protected

  def sign_up_params
    params.require(:user).permit(:email, :password)
  end

  def after_sign_up_path_for(resource)
    onboarding_profile_info_path
  end
end
