class PostsController < ApplicationController
  include Pagy::Backend

  before_action :set_post, only: [ "show", "edit", "update", "destroy" ]

  def index
    @posts = Post.all

    @pagy, @posts = pagy(@posts, items: 12)
  end

  def new
    @post = Post.new
  end

  def create
    @post = Post.new(post_params)
    if @post.save
      redirect_to edit_post_path(@post.slug), notice: "post was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def show
  end

  def edit
  end

  def update
    if @post.update(post_params)
      redirect_to edit_post_path(@post.slug), notice: "post was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @post.destroy
    redirect_to posts_path, notice: "post was successfully destroyed."
  end

  def remove_image
    @post.image.purge
    redirect_to edit_post_path(post_slug: @post.slug), notice: "Image removed successfully."
  end

  private

  def set_post
    @post = Post.find_by!(slug: params[:slug])
  end

  def post_params
    params.require(:post).permit(:title, :slug)
  end
end
