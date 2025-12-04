class CommentsController < ApplicationController
  load_and_authorize_resource :memory
  load_and_authorize_resource :comment, through: :memory

  def create
    @comment.user = current_user
    if @comment.save
      redirect_to memory_path(@memory)
    else
      render :new
    end
  end

  def destroy
    @comment.destroy
    redirect_to memory_path(@memory)
  end

  private

  def comment_params
    params.require(:comment).permit(:body)
  end
end
