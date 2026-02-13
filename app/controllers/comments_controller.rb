class CommentsController < ApplicationController
  load_and_authorize_resource except: [ :create ]
  before_action :set_comment, only: %i[ show edit update destroy ]

  def show
  end

  def edit
  end

  def create
    @comment = current_user.comments.new(comment_params)

    if @comment.save
      @commentable = @comment.commentable
    end
  end

  def update
    respond_to do |format|
      if @comment.update(comment_params)
        format.html { redirect_to @comment, notice: "Comment was successfully updated.", status: :see_other }
        format.json { render :show, status: :ok, location: @comment }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @comment.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @commentable = @comment.commentable
    @comment.destroy!
  end

  private

    def set_comment
      @comment = Comment.find(params.expect(:id))
    end

    def comment_params
      params.expect(comment: [ :body, :commentable_type, :commentable_id ])
    end
end
