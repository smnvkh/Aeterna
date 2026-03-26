class ProfileController < ApplicationController
  load_and_authorize_resource
  before_action :set_my_profile, only: [ :my, :edit, :update ]

  def my
    @profile = current_user.profile
    @memories = current_user.memories
    render :show
  end

  def show
    @memory = Memory.find(params[:id])
    @profile = @memory.family_member.user.profile if @memory.family_member&.user

    # Инициализация воспоминаний
    if @profile.present?
      @memories = @profile.user.memories.order(date: :desc)
    else
      @memories = Memory.none
    end

    set_meta_tags(
      title: @memory.title,
      description: "Воспоминание: #{@memory.title}",
      keywords: "family, memory, #{@memory.title}",
      og: {
        title: @memory.title,
        type: "website",
        url: memory_url(@memory)
      }
    )
  end

  def edit
  end

  def update
    @profile = current_user.profile
    if @profile.update(profile_params)
      redirect_to my_profile_path
    else
      render :edit
    end
  end

  private

  def set_my_profile
    @profile = current_user.profile
  end

  def profile_params
    params.expect(profile: [ :name, :birthday, :avatar ])
  end
end
