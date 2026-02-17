class Api::V1::SessionsController < Devise::SessionsController
  include JwtAuth

  skip_before_action :verify_authenticity_token
  skip_before_action :verify_signed_out_user, only: [ :destroy ]
  before_action :load_user_by_email, only: [ :create ]
  before_action :load_user_by_jti, only: [ :authorize_by_jwt, :destroy ]

  def authorize_by_jwt
    render json: {
      messages: "Authorized Successfully",
      is_success: true,
      email: @user.email,
      role: @user.role,
      invite_code: @user.owner? ? @user.family&.invite_code : nil
    }, status: :ok
  end

  def create
    payload = @user.as_json(only: [ :jti ])

    if @user.valid_password?(sign_in_params[:password])
      render json: {
        messages: "Sign In Successful",
        is_success: true,
        jwt: encrypt_payload(payload)
      }, status: :ok
    else
      render json: {
        messages: "Sign In Failed - Unauthorized",
        is_success: false
      }, status: :unauthorized
    end
  end

  def destroy
    if @user && @user.update_column(:jti, SecureRandom.uuid)
      render json: {
        messages: "Signed Out Successfully",
        is_success: true
      }, status: :ok
    else
      render json: {
        messages: "Sign Out Failed - Unauthorized",
        is_success: false
      }, status: :unauthorized
    end
  end

  private

    def load_user_by_email
      @user = User.find_for_database_authentication(email: sign_in_params[:email])

      unless @user
        render json: {
          messages: "Sign In Failed - Unauthorized",
          is_success: false
        }, status: :unauthorized
      end
    end
end
