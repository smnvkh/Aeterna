class Api::V1::MemoriesController < ApplicationController
  skip_before_action :verify_authenticity_token, only: [ :create ]
  before_action :load_user_by_jti, only: [ :create ]
  def index
    @memories = Memory.order(created_at: :desc)
  end

  def show
    memory = Memory.find_by(id: params[:id])

    if memory
      render json: memory.as_json(
        include: {
          family_member: { only: [ :id ], methods: [ :to_s ] }
        },
        methods: [ :image_url ]
      )
    else
      render json: { error: "Memory not found" }, status: :not_found
    end
  end


  def create
    family_member = @user.family.family_members.find(params[:memory][:family_member_id])

    memory = family_member.memories.new(memory_params)
    memory.family = @user.family

    if memory.save
      render json: { id: memory.id }, status: :created
    else
      render json: { errors: memory.errors.full_messages }, status: :unprocessable_entity
    end
  end

  private

  def memory_params
    params.require(:memory).permit(:title, :family_member_id, :body, :date, :image, :tag_list, :category_list)
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

  def decrypt_payload
    bearer = request.headers["Authorization"]
    jwt = bearer.split(" ").last
    jwt_signing_key = Rails.application.credentials.jwt_signing_key!
    token = JWT.decode(jwt, jwt_signing_key, true, { algorithm: "HS256" })
  end
end
