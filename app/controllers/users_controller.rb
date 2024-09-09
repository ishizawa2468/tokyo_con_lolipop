class UsersController < ApplicationController
  def new
    redirect_if_logged_in
    @user = User.new
  end

  def create
    watchword = Watchword.find_by(word: params[:user][:watchword])
    @user = User.new(user_params)

    if watchword
      if @user.save
        log_in @user
        redirect_to root_path, notice: 'ユーザー登録できました。'
      else
        render :new, status: :unprocessable_entity
      end
    else
      flash.now[:alert] = '合言葉が違います'
      render :new, notice: '合言葉が違います。', status: :unprocessable_entity
    end
  end

  private

  def user_params
    params.require(:user).permit(:nickname, :password, :password_confirmation, :watchword)
  end
end
