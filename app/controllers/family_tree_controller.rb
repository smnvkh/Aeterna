class FamilyTreeController < ApplicationController
  load_and_authorize_resource :family_member, only: [ :index, :show ]

  def index
    # Если у пользователя есть семья, он может видеть дерево семьи
    @members = current_user.family.family_members
  end

  def show
    # Должен быть доступ только к членам своей семьи
    @member = FamilyMember.find(params[:id])
  end
end
