class MemoriesController < ApplicationController
  load_and_authorize_resource
  before_action :set_memory, only: %i[ show edit update destroy ]

  def timeline
    if current_user.family
      @memories_by_year = current_user.family.memories
        .order(:date)
        .group_by { |m| m.date.year }
    else
      @memories_by_year = {}
    end

    # Мета-теги для страницы «Лента времени»
    set_meta_tags(
      title: "Лента времени",
      description: "Просмотр всех воспоминаний вашей семьи в хронологическом порядке",
      keywords: "family, memories, timeline",
      og: {
        title: "Лента времени",
        type: "website",
        url: timeline_url
      }
    )
  end

  def family_web
    if current_user.family
      @memories = current_user.family.memories.order(:date)
    else
      @memories = Memory.none
    end

    set_meta_tags(
      title: "Сеть семейных воспоминаний",
      description: "Просмотр всех воспомианий вашей семьи",
      keywords: "family, web, relatives, memories",
      og: {
        title: "Сеть семейных воспоминаний",
        type: "website",
        url: family_web_url
      }
  )
  end

  def my
    @memories = current_user.memories.order(created_at: :desc)
    render :index

    set_meta_tags(
      title: "Мои воспоминания",
      description: "Просмотр всех воспоминаний, созданных вами",
      keywords: "family, memories",
      og: {
        title: "Мои воспоминания",
        type: "website",
        url: my_memories_url
      }
  )
  end

  def by_tag
    @memories = Memory.tagged_with(params[:tag])
    render :index
  end

  def new
    @memory = Memory.new
  end

  def create
    @memory = Memory.new(memory_params)
    @memory.family = current_user.family

    respond_to do |format|
      if @memory.save
        format.html { redirect_to @memory, notice: "Memory was successfully created." }
      else
        format.html { render :new, status: :unprocessable_entity }
      end
    end
  end

  def update
    if @memory.update(memory_params)
      redirect_to @memory, notice: "Memory was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @memory.destroy
    redirect_to timeline_path, notice: "Memory was successfully destroyed."
  end

  private

  def set_memory
    @memory = Memory.find(params[:id])
  end

  def memory_params
    params.require(:memory).permit(:title, :family_member_id, :body, :date, :image, :tag_list, :category_list)
  end
end
