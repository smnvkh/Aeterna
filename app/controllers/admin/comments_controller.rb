class Admin::CommentsController < ApplicationController
  load_and_authorize_resource
  before_action :set_memory, only: %i[ create destroy ]

  def create
    @comment = @memory.comments.new(comment_params)
    @comment.user = current_user

    if @comment.save
      redirect_to admin_memory_path(@memory)
    else
      render :new
    end
  end

  def destroy
    @comment = @memory.comments.find(params[:id])
    @comment.destroy
    redirect_to admin_memory_path(@memory)
  end

  private

  def set_memory
    @memory = Memory.find(params[:memory_id])
  end

  def comment_params
    params.require(:comment).permit(:body)
  end
end
