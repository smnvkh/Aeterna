class CommentsController < ApplicationController
  before_action :set_memory, only: %i[ create destroy ]
  before_action :authenticate_user!

  def create
    @comment = @memory.comments.create(params[:comment].permit(:body))
    redirect_to memory_path(@memory)
  end

  def destroy
    @comment = @memory.comments.find(params[:id])
    @comment.destroy
    redirect_to memory_path(@memory)
  end

  private

    def set_memory
      @memory = Memory.find(params[:memory_id])
    end
end
