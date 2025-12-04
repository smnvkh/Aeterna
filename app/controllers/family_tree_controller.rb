class FamilyTreeController < ApplicationController
  load_and_authorize_resource :family_member, only: [ :index, :show ]

  def index
    @members = current_user.family.family_members
  end

  def show
    @member = current_user.family.family_members.find(params[:id])
  end
end
