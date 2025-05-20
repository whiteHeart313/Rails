class CommentsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_post
  before_action :set_comment, only: [:update, :destroy]
  before_action :authorize_user!, only: [:update, :destroy]

  def index
    @comments = @post.comments.order(created_at: :desc)
    render json: @comments, status: :ok
  end

  def show 
    @comment = @post.comments.find(params[:id])
    render json: @comment, status: :ok
  end

  def create
    @comment = @post.comments.build(comment_params)
    @comment.user = current_user

    if @comment.save
      Rails.logger.info "Comment created by #{current_user.id}: #{@comment.inspect}"
      render json:{
        message: 'Comment was successfully added.',
        comment: @comment,
        post: @post,
      }, status: :created
    else
      Rails.logger.error "Comment creation failed: #{@comment.errors.details.first&.dig(1, 0, :error).to_s}"
      render json: {
        message: "Failed to add comment. #{@comment.errors.details.first&.dig(1, 0, :error).to_s}" ,
        post: @post
      }, status: :unprocessable_entity
    end
  end

  def update
    if @comment.update(comment_params)
      Rails.logger.info "Comment updated by #{current_user.id}: #{@comment.inspect}"
      render json:{
        message: "Comment was successfully updated." , 
        post :@post
      }, status: :ok
    else
      Rails.logger.error "Comment update failed: #{@comment.errors.details.first&.dig(1, 0, :error).to_s}"
      render json:{
        message: "Failed to update comment. #{@comment.errors.details.first&.dig(1, 0, :error).to_s}" ,
        post: @post
      }, status: :unprocessable_entity
    end
  end

  def destroy
    @comment.destroy
    render json:{message: "Comment was successfully deleted." , post : @post } , status: :no_content
  end

  private

  def set_post
    @post = Post.find(params[:post_id])
  end

  def set_comment
    @comment = Comment.find(params[:id])
  end

  def comment_params
    params.require(:comment).permit(:body)
  end

  def authorize_user!
    unless @comment.user == current_user
      redirect_to @post, alert: 'You are not authorized to perform this action.'
    end
  end
end
