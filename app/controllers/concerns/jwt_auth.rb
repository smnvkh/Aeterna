module JwtAuth
  extend ActiveSupport::Concern

  included do
    helper_method :load_user_by_jti, :encrypt_payload, :decrypt_payload
  end

  def load_user_by_jti
    @user = User.find_by_jti(decrypt_payload[0]["jti"])

    unless @user
      render json: {
        messages: "Unauthorized",
        is_success: false
      }, status: :unauthorized
    end
  end

  def encrypt_payload(payload)
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
