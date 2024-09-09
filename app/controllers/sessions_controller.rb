class SessionsController < ApplicationController
  def new
    redirect_if_logged_in
  end

  def create
    user = User.find_by(nickname: params[:session][:nickname])
    if user&.authenticate(params[:session][:password])
      # ログイン成功
      reset_session
      log_in user
      redirect_to root_path, notice: 'ログインしました。'
    else
      # ログイン失敗
      flash.now[:alert] = 'ニックネームまたはパスワードが間違っています。'
      render :new, status: :unauthorized
    end
  end

  def destroy
    log_out
    redirect_to root_path, notice: 'ログアウトしました。', status: :see_other
  end
end
