class CommentsController < ApplicationController
  before_action :logged_in_user
  before_action :set_post
  before_action :set_comment, only: [:edit, :update, :destroy]
  before_action :check_comment_owner, only: [:edit, :update, :destroy]

  def create
    @comment = @post.comments.build(comment_params)
    @comment.user = current_user
    @comment.poster_name = "匿名コンサルタント" if @comment.poster_name.blank?

    if @comment.save
      redirect_to post_path(@post), notice: 'コメントが投稿されました。'
    else
      redirect_to post_path(@post), alert: 'コメントの投稿に失敗しました...', status: :unprocessable_entity
    end
  end

  def edit
    # 編集フォームを表示するためにPostsController#showにリダイレクト
    redirect_to post_path(@post, edit_comment_id: @comment.id)
  end

  def update
    comment_params_with_default = comment_params
    comment_params_with_default[:poster_name] = "匿名コンサルタント" if comment_params_with_default[:poster_name].blank?

    if @comment.update(comment_params_with_default)
      redirect_to post_path(@post), notice: 'コメントが更新されました。'
    else
      render :edit, alert: 'コメントが更新されませんでした...', status: :unprocessable_entity
    end
  end

  def destroy
    if @comment.destroy
      redirect_to post_path(@post), notice: 'コメントが削除されました。'
    else
      redirect_to post_path(@post), alert: 'コメントの削除に失敗しました...', status: :unprocessable_entity
    end
  rescue ActiveRecord::RecordNotFound
    redirect_to post_path, alert: '指定されたコメントが見つかりませんでした。', status: :unprocessable_entity
  end

  private

  def set_post
    @post = Post.find(params[:post_id])
  end

  def set_comment
    @comment = @post.comments.find(params[:id])
  end

  def check_comment_owner
    unless current_user == @comment.user
      redirect_to post_path(@post), alert: 'この操作を行う権限がありません。', status: :forbidden
    end
  end

  def comment_params
    params.require(:comment).permit(:content, :poster_name)
  end
end
