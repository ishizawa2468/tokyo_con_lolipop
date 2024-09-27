class PostsController < ApplicationController
  before_action :logged_in_user, only: [:index, :show, :new, :create, :edit, :update, :destroy, :like]
  before_action :set_post, only: [:show, :edit, :update, :destroy]
  before_action :check_post_owner, only: [:edit, :update, :destroy]

  def index
    @q = Post.ransack(params[:q])
    @posts = @q.result(distinct: true)
               .includes(:user, :comments, image_attachment: :blob)
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
      handle_post_error(:new)
    end
  rescue => e
    handle_image_error(e)
  end

  def edit
  end


  def update
    post_params_with_default = post_params
    post_params_with_default[:poster_name] = "匿名コンサルタント" if post_params_with_default[:poster_name].blank?

    # 画像の処理
    if params[:post][:remove_image] == '1'
      @post.image.purge
    elsif params[:post][:image].present?
      @post.image.attach(params[:post][:image])
    end

    if @post.update(post_params_with_default)
      redirect_to @post, notice: 'ポストが更新されました。'
    else
      handle_post_error(:edit)
    end
  rescue => e
    handle_image_error(e)
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
    params.require(:post).permit(:title, :content, :poster_name, :image)
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

  def handle_post_error(action)
    @posts = Post.includes(:user, :comments).order(created_at: :desc).page(params[:page]).per(10) if action == :new
    flash.now[:alert] = '投稿に失敗しました。'
    flash.now[:alert] << "\n" + @post.errors.full_messages.join("\n") if @post.errors.any?
    render action, status: :unprocessable_entity
  end

  def handle_image_error(error)
    Rails.logger.error "Error during image processing: #{error.message}"
    Rails.logger.error error.backtrace.join("\n")
    flash.now[:alert] = "画像処理に失敗しました。別の画像を試すか、後でもう一度お試しください。"
    render :new, status: :unprocessable_entity
  end
end
