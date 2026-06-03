class PagesController < ApplicationController
  before_action :authenticate_user!, only: [ :home ]

  def home
    @subscription = Subscription.new
    @recent_memories = if user_signed_in? && current_user.family
      current_user.family.memories.order(created_at: :desc).limit(4)
    else
      Memory.none
    end
    @family_members = if user_signed_in? && current_user.family
      current_user.family.family_members
        .where.not(user_id: current_user.id)
        .includes(user: { profile: { avatar_attachment: :blob } })
    else
      FamilyMember.none
    end

    set_meta_tags(
      title: "Главная страница",
      description: "Добро пожаловать! Узнайте больше о вашей семье и воспоминаниях.",
      keywords: "family, memories, home",
      og: {
        title: "Главная страница",
        type: "website",
        url: root_url
      }
    )
  end

  def about
    @subscription = Subscription.new

    set_meta_tags(
      title: "О проекте",
      description: "Узнайте больше о нашей семейной памяти и истории",
      keywords: "about, family, history, memories",
      og: {
        title: "О проекте",
        type: "website",
        url: pages_about_url
      }
    )
  end
end
