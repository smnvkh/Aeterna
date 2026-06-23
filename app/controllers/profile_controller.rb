class ProfileController < ApplicationController
  load_and_authorize_resource
  before_action :set_my_profile, only: [ :my, :edit, :update ]

  def my
    @profile = current_user.profile
    @memories = profile_memories(@profile)
    @collections = profile_collections(@profile)
    render :show
  end

  def show
    @profile = Profile.find(params[:id])
    @memories = profile_memories(@profile)
    @collections = profile_collections(@profile)
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

  def profile_memories(profile)
    return Memory.none unless profile&.user&.family_member
    profile.user.family_member.memories.order(date: :desc)
  end

  def profile_collections(profile)
    return Collection.none unless profile&.user&.family_member
    profile.user.family_member.collections.order(date: :desc)
  end

  def profile_params
    params.expect(profile: [ :name, :birthday, :avatar ])
  end
end
