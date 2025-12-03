class Admin::FamilyTreeController < ApplicationController
  load_and_authorize_resource :family_member, only: [ :index, :show ]
  def index
    @members = FamilyMember.all
  end

  def show
    @member = FamilyMember.find(params[:id])
  end
end
