class PostsController < ApplicationController
  before_action :authenticate_request!, except: [:index, :show]
  before_action :set_post, only: [:show, :update, :destroy]
  before_action :authorize_user!, only: [ :update, :destroy]

  def index
    Rails.logger.info "Fetching all posts"
    Rails.logger.info "Current user: #{current_user.inspect}"
    posts = Post.includes(:comments, :tags)
                .order(created_at: :desc)
                .page(params[:page])
                .per(params[:per_page] || 10)

    render json: {
      posts: posts,
      current_page: posts.current_page,
      total_pages: posts.total_pages,
      total_count: posts.total_count
    }, status: :ok
  end

  def show
    Rails.logger.info "Fetching post with ID: #{params[:id]}"
    Rails.logger.info "Current user: #{current_user.inspect}"
    comments = @post.comments.order(created_at: :desc)
    tags = @post.tags.order(created_at: :desc)
    render json: {
      post: @post,
      comments: comments,
      tags: tags
    }, status: :ok
  end

  def create
    @post = current_user.posts.build(post_params)
    Rails.logger.info "Creating post with params: #{post_params.inspect}"
    Rails.logger.info "Current user: #{current_user.inspect}"    
    if @post.save
      Rails.logger.info "Post created successfully: #{@post.id}"
      render json: { message: 'Post was successfully created.' }, status: :created
    else
      Rails.logger.error "Post creation failed: #{@post.errors.details.first&.dig(1, 0, :error).to_s}"
      render json: { errors: [@post.errors.details.first&.dig(1, 0, :error).to_s] }, status: :unprocessable_entity
    end
  end



  def update
    assign_tags if params[:post][:tag_ids].present?
    
    if @post.update(post_params)
      render json: { message: 'Post was successfully updated.' }, status: :ok
    else
      render json: { errors: @post.errors.full_messages }, status: :unprocessable_entity
    end
  
  end

  def destroy
    @post.destroy!
    render json: { message: 'Post was successfully deleted.' }, status: :no_content
  rescue ActiveRecord::RecordNotDestroyed
    render json: { errors: ['Post could not be deleted.'] }, status: :unprocessable_entity
  end

  private

  def set_post
    @post = Post.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render json: { error: 'Post not found' }, status: :not_found
  end

  def post_params
    params.require(:post).permit(:title, :body, tag_ids: [] , tags_attributes:[:name])
  end

  def authorize_user!
    unless post.user == current_user
      render json: {message: 'You are not authorized to perform this action.'}, status: :forbidden 
    end
  end

  def assign_tags
    @post.tag_ids = params[:post][:tag_ids]
  end

end