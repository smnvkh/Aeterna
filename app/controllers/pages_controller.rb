class PagesController < ApplicationController
  def home
    @subscription = Subscription.new

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
