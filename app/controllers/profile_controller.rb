class ProfileController < ApplicationController
  load_and_authorize_resource
  before_action :set_my_profile, only: [ :my, :edit, :update ]

  def my
    @profile = current_user.profile
    @memories = current_user.memories
    render :show
  end

  def show
    @profile = Profile.find(params[:id])

    # Инициализация воспоминаний
    if @profile.user.present?
      @memories = @profile.user.memories.order(date: :desc)
    else
      @memories = Memory.none
    end

    set_meta_tags(
      title: @profile.name,
      description: "Профиль пользователя #{@profile.name}",
      keywords: "profile, user, #{@profile.name}",
      og: {
        title: @profile.name,
        type: "profile",
        url: profile_url(@profile)
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
