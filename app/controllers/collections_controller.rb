class CollectionsController < ApplicationController
  load_and_authorize_resource
  before_action :set_collection, only: %i[ show edit update destroy ]
  before_action :set_my_memories, only: %i[ new create edit update ]

  def show
  end

  def new
    @collection = Collection.new
  end

  def create
    @collection = Collection.new(collection_params)
    @collection.family = current_user.family
    @collection.family_member = current_user.family_member

    if @collection.save
      redirect_to @collection, notice: "Подборка успешно создана."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @collection.update(collection_params)
      redirect_to @collection, notice: "Подборка успешно обновлена."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @collection.destroy
    redirect_to my_profile_path, notice: "Подборка успешно удалена."
  end

  private

  def set_collection
    @collection = Collection.find(params[:id])
  end

  def set_my_memories
    memories = current_user.family_member&.memories || Memory.none
    @memories = memories.order(date: :desc)
  end

  def collection_params
    params.require(:collection).permit(:title, :date, category_list: [], memory_ids: [])
  end
end
