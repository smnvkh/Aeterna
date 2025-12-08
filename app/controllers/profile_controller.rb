class ProfileController < ApplicationController
  load_and_authorize_resource
  before_action :set_my_profile, only: [ :my, :edit, :update ]

  def my
    render :show
  end
  def show
    @profile = Profile.find(params[:id])
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
      params.expect(profile: [ :name, :avatar ])
    end
end
