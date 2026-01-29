class FamilyTreeController < ApplicationController
  load_and_authorize_resource :family_member, only: [ :index, :show ]

  def index
    @members = current_user.family.family_members

    set_meta_tags(
      title: "Семейное древо",
      description: "Полная история вашей семьи и родственные связи",
      keywords: "family, tree, genealogy, relatives",
      og: {
        title: "Семейное древо",
        type: "website",
        url: family_tree_url
      }
    )
  end

  def show
    @member = current_user.family.family_members.find(params[:id])
    @memories = @member.memories.order(date: :desc)

    set_meta_tags(
      title: @family_member.to_s,
      description: "Информация и воспоминания о #{@family_member}",
      keywords: "family, member",
      og: {
        title: @family_member.to_s,
        type: "website",
        url: family_tree_url(@family_member)
      }
    )
  end
end
