class PostsController < ApplicationController
  before_action :logged_in_user, only: [:index, :show, :new, :create, :edit, :update, :destroy]
  before_action :set_post, only: [:show, :edit, :update, :destroy]
  before_action :check_post_owner, only: [:edit, :update, :destroy]

  def index
    @q = Post.ransack(params[:q])
    @posts = @q.result.includes(:user, :comments)
               .order(created_at: :desc)
               .page(params[:page]).per(10)
  end

  def show
    @post = Post.find(params[:id])
    @comments = @post.comments.order(:created_at).each_with_index.map do |comment, index|
      comment.instance_variable_set(:@comment_number, index + 1)
      comment
    end
    @comment = params[:edit_comment_id] ? @post.comments.find(params[:edit_comment_id]) : Comment.new
  end

  def new
    @post = Post.new
  end

  def create
    @post = current_user.posts.build(post_params)
    @post.poster_name = "匿名コンサルタント" if @post.poster_name.blank?

    if @post.save
      redirect_to posts_path, notice: 'Postが投稿されました。'
    else
      @posts = Post.includes(:user, :comments).order(created_at: :desc).page(params[:page]).per(10)
      redirect_to :index, alert: 'Post投稿に失敗しました。', status: :unprocessable_entity
    end
  rescue => e
    Rails.logger.error "Error during image upload: #{e.message}"
    Rails.logger.error e.backtrace.join("\n")
    render :new, alert: "画像投稿に失敗しました。"
  end

  def edit
  end

  def update
    post_params_with_default = post_params
    post_params_with_default[:poster_name] = "匿名コンサルタント" if post_params_with_default[:poster_name].blank?

    if @post.update(post_params_with_default)
      redirect_to @post, notice: 'ポストが更新されました。'
    else
      render :edit, alert: 'ポストの編集に失敗しました...', status: :unprocessable_entity
    end
  end

  def destroy
    if @post.destroy
      redirect_to posts_path, notice: 'ポストを削除しました。'
    else
      redirect_to @post, alert: 'ポストの削除に失敗しました...', status: :unprocessable_entity
    end
  rescue ActiveRecord::RecordNotFound
    redirect_to posts_path, alert: '指定されたポストが見つかりませんでした。', status: :unprocessable_entity
  end

  def like
    @post = Post.find(params[:id])
    @liked = @post.toggle_like(current_user)
    @likes_count = @post.likes_count

    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to @post }
      format.json { render json: { liked: @liked, likesCount: @likes_count } }
    end
  end

  private

  def post_params
    params.require(:post).permit(:title, :content, :image, :poster_name)
  end

  def set_post
    @post = Post.find(params[:id])
  end

  def check_post_owner
    unless current_user == @post.user
      flash[:alert] = "この操作を行う権限がありません。"
      redirect_to posts_path, status: :forbidden
    end
  end
end
