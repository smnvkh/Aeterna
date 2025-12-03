class MemoriesController < ApplicationController
  load_and_authorize_resource
  before_action :set_memory, only: %i[ show edit update destroy ]

  def timeline
    if current_user.family
      @memories_by_year = Memory
        .joins(:user)
        .where(users: { family_id: current_user.family_id })
        .order(:date)
        .group_by { |m| m.date.year }
    else
      @memories = Memory.none
    end
  end

  def family_web
    if current_user.family
      @memories = Memory.joins(:user)
                        .where(users: { family_id: current_user.family.id })
    else
      @memories = Memory.none
    end
  end

  def family_tree
    @family_members = current_user.family_members
  end

  # GET /memories or /memories.json
  # def index
  #   @memories = Memory.all
  # end

  # GET /memories/1 or /memories/1.json
  def show
  end

  # GET /memories/new
  def new
    @memory = Memory.new
  end

  # GET /memories/1/edit
  def edit
  end

  # POST /memories or /memories.json
  def create
    @memory = Memory.new(memory_params)
    @memory.user = current_user

    respond_to do |format|
      if @memory.save
        format.html { redirect_to @memory, notice: "Memory was successfully created." }
        format.json { render :show, status: :created, location: @memory }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @memory.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /memories/1 or /memories/1.json
  def update
    respond_to do |format|
      if @memory.update(memory_params)
        format.html { redirect_to @memory, notice: "Memory was successfully updated.", status: :see_other }
        format.json { render :show, status: :ok, location: @memory }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @memory.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /memories/1 or /memories/1.json
  def destroy
    @memory.destroy!

    respond_to do |format|
      format.html { redirect_to timeline_path, notice: "Memory was successfully destroyed.", status: :see_other }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_memory
      @memory = Memory.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def memory_params
      params.require(:memory).permit(:title, :family_member_id, :body, :date, :image)
    end
end
