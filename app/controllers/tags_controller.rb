class TagsController < ApplicationController
  before_action :authenticate_request!, except: [:index, :show]
  before_action :set_tag, only: [:show, :update, :destroy]

  def index
    tags = Tag.all
    render json: tags, status: :ok
  end

  def show
    posts = @tag.posts.order(created_at: :desc)
    render json: {
      tag: @tag,
      posts: posts
    }, status: :ok
  end

  def create
    @tag = Tag.new(tag_params)

    if @tag.save
      render json: {
        message: 'Tag was successfully created.',
        tag: @tag
      }, status: :created
    else
      render json: {
        errors: @tag.errors.full_messages
      }, status: :unprocessable_entity
    end
  end

  def update
    if @tag.update(tag_params)
      render json: {
        message: 'Tag was successfully updated.',
        tag: @tag
      }, status: :ok
    else
      render json: {
        errors: @tag.errors.full_messages
      }, status: :unprocessable_entity
    end
  end

  def destroy
    @tag.destroy!
    render json: {
      message: 'Tag was successfully deleted.'
    }, status: :no_content
  rescue ActiveRecord::RecordNotDestroyed
    render json: {
      errors: ['Tag could not be deleted.']
    }, status: :unprocessable_entity
  end

  private

  def set_tag
    @tag = Tag.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render json: { error: 'Tag not found' }, status: :not_found
  end

  def tag_params
    params.require(:tag).permit(:name)
  end
end