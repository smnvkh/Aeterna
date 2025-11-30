class Admin::FamilyTreeController < ApplicationController
  authorize_resource class: false
  def index
    @members = FamilyMember.all
  end

  def show
    @member = FamilyMember.find(params[:id])
  end
end
