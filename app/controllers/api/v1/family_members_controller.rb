class Api::V1::FamilyMembersController < ApplicationController
  before_action :load_user_by_jti, only: [ :index ]

  def index
     render json: @user.family.family_members
  end

  private

  def load_user_by_jti
    @user = User.find_by_jti(decrypt_payload[0]["jti"])

    unless @user
      render json: {
        messages: "Unauthorized",
        is_success: false
      }, status: :unauthorized
    end
  end

  def decrypt_payload
    bearer = request.headers["Authorization"]
    jwt = bearer.split(" ").last
    jwt_signing_key = Rails.application.credentials.jwt_signing_key!
    token = JWT.decode(jwt, jwt_signing_key, true, { algorithm: "HS256" })
  end
end
