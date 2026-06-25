class FamilyMembersController < ApplicationController
  load_and_authorize_resource
  before_action :set_family_member, only: %i[ show edit update destroy add_relation ]

  # GET /family_members or /family_members.json
  def index
    @family_members = current_user.family.family_members
  end

  # GET /family_members/1 or /family_members/1.json
  def show
  end

  # GET /family_members/new
  def new
    @family_member = FamilyMember.new
  end

  # GET /family_members/1/edit
  def edit
  end

  # POST /family_members or /family_members.json
  def create
    @family_member = FamilyMember.new(family_member_params)
    # Если пользователь не передан в форме — ставим current_user как владелец
    @family_member.family ||= current_user.family

    respond_to do |format|
      if @family_member.save
        format.html { redirect_to @family_member, notice: "Family member was successfully created." }
        format.json { render :show, status: :created, location: @family_member }
      else
        Rails.logger.debug "FamilyMember create failed: #{@family_member.errors.full_messages.inspect}"
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @family_member.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /family_members/1 or /family_members/1.json
  def update
    respond_to do |format|
      # Не меняем владельца при update, если не передали user_id намеренно
      if @family_member.update(family_member_params)
        format.html { redirect_to @family_member, notice: "Family member was successfully updated.", status: :see_other }
        format.json { render :show, status: :ok, location: @family_member }
      else
        Rails.logger.debug "FamilyMember update failed: #{@family_member.errors.full_messages.inspect}"
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @family_member.errors, status: :unprocessable_entity }
      end
    end
  end

  # POST /family_members/1/add_relation
  def add_relation
    existing_member = if params[:existing_member_id].present?
      current_user.family.family_members.find_by(id: params[:existing_member_id])
    end

    builder = FamilyRelationBuilder.new(
      source: @family_member,
      relation_type: params[:relation_type],
      name: params[:name],
      gender: params[:gender].presence,
      existing_member: existing_member,
      birth_date: params[:birth_date].presence,
      death_date: params[:death_date].presence
    )

    if builder.call
      redirect_to family_tree_path, notice: "#{builder.member.name} добавлен(а) в дерево."
    else
      redirect_to family_tree_path, alert: builder.errors.to_a.to_sentence
    end
  end

  # DELETE /family_members/1 or /family_members/1.json
  def destroy
    @family_member.destroy!

    respond_to do |format|
      format.html { redirect_to family_tree_path, notice: "Family member was successfully destroyed.", status: :see_other }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_family_member
      @family_member = current_user.family.family_members.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def family_member_params
      params.require(:family_member).permit(
        :name,
        :gender,
        :mother_id,
        :father_id,
        :spouse_id,
        :birth_date,
        :death_date
      )
    end
end
