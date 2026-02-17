class Api::V1::RegistrationsController < Devise::RegistrationsController
  include JwtAuth

  skip_before_action :verify_authenticity_token

  def create
    family = if params[:user][:invite_code].present?
                Family.find_by(invite_code: params[:user][:invite_code])
    else
                Family.create
    end

    unless family
      return render json: { messages: "Неверный код семьи", is_success: false }, status: :unprocessable_entity
    end

    @user = User.new(user_params)
    @user.family = family
    @user.role = family.users.empty? ? :owner : :member

    if @user.save
      payload = @user.as_json(only: [ :jti ])

      render json: {
            messages: "Signed Up Successfully",
            is_success: true,
            jwt: encrypt_payload(payload),
            invite_code: @user.owner? ? @user.family.invite_code : nil,
            email: @user.email
          }, status: :ok
    else
      render json: {
        messages: "Sign Up Failed",
        is_success: false
      }, status: :unprocessable_entity
    end
  end

  private

  def user_params
    params.expect(user: [ :email, :password, :password_confirmation ])
  end
end
