class Api::V1::SessionsController < Devise::SessionsController
  skip_before_action :verify_authenticity_token
  before_action :load_user_by_email, only: [ :create ]
  before_action :load_user_by_jti, only: [ :authorize_by_jwt ]

  def authorize_by_jwt
    render json: {
      messages: "Authorized Successfully",
      is_success: true,
      email: @user[:email]
    }, status: :ok
  end

  def create
    if @user.valid_password?(sign_in_params[:password])
      render json: {
        messages: "Sign In Successful",
        is_success: true,
        jwt: encrypt_payload
      }, status: :ok
    else
      render json: {
        messages: "Sign In Failed - Unauthorized",
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

  def load_user_by_jti
    @user = User.find_by_jti(decrypt_payload[0]["jti"])

    unless @user
      render json: {
        messages: "Sign Out Failed — Unauthorized",
        is_success: false
      }, status: :unauthorized
    end
  end

  def encrypt_payload
    payload = @user.as_json(only: [ :jti ])
    jwt_signing_key = Rails.application.credentials.jwt_signing_key!
    token = JWT.encode(payload, jwt_signing_key, "HS256")
  end

  def decrypt_payload
    bearer = request.headers["Authorization"]
    jwt = bearer.split(" ").last
    jwt_signing_key = Rails.application.credentials.jwt_signing_key!
    token = JWT.decode(jwt, jwt_signing_key, true, { algorithm: "HS256" })
  end
end
