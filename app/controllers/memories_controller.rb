class MemoriesController < ApplicationController
  load_and_authorize_resource
  before_action :set_memory, only: %i[ show edit update destroy add_to_collection ]

  def show
    @memory = Memory.find(params[:id])
      if @memory.family_member && @memory.family_member.user
        @profile = @memory.family_member.user.profile
      else
        @profile = nil  # В случае отсутствия профиля, избегаем ошибки
      end
    @collections = current_user.family_member ? current_user.family_member.collections.order(created_at: :desc) : Collection.none
  end

  def add_to_collection
    collection = current_user.family_member.collections.find(params[:collection_id])
    collection.memories << @memory unless collection.memories.exists?(@memory.id)
    redirect_to @memory, notice: "Воспоминание добавлено в подборку «#{collection.title}»."
  end

  def timeline
    @memories = current_user.family ? current_user.family.memories : Memory.none

    @selected_type = Memory::TYPES.include?(params[:type]) ? params[:type] : "all"
    @memories = @memories.of_type(@selected_type) unless @selected_type == "all"

    @sort = MemoriesHelper::SORT_LABELS.key?(params[:sort]) ? params[:sort] : "newest"
    @memories = @sort == "oldest" ? @memories.order(date: :asc) : @memories.order(date: :desc)

    @zoom = params[:zoom].to_i
    @zoom = MemoriesHelper::DEFAULT_ZOOM unless (1..MemoriesHelper::ZOOM_LEVELS.size).cover?(@zoom)

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
    @memory.family_member = current_user.family_member

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
    profile = @memory.family_member&.user&.profile
    @memory.destroy
    if profile
      redirect_to profile_path(profile), notice: "Memory was successfully destroyed."
    else
      redirect_to timeline_path, notice: "Memory was successfully destroyed."
    end
  end

  private

  def set_memory
    @memory = Memory.find(params[:id])
  end

  def memory_params
    params.require(:memory).permit(:title, :family_member_id, :body, :date, :image, tag_list: [], category_list: [])
  end
end
