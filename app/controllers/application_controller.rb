class ApplicationController < ActionController::Base
  include SessionsHelper

  before_action :log_access
  before_action :check_admin_access

  private

  def logged_in_user
    unless logged_in?
      redirect_to login_path
    end
  end

  def authenticate_admin!
    unless current_user&.admin?
      raise ActionController::RoutingError.new('Not Found')
    end
  end

  def check_admin_access
    if logged_in? && current_user.admin?
      flash.now[:warning] = "現在、管理者アカウントでログインしています。
                             \n・管理者ページ: \n個人情報の取り扱いに注意してください。
                             \n・一般ユーザー向けページ: \n投稿などの操作には十分注意してください。"
    end
  end

  def redirect_if_logged_in
    if logged_in?
      redirect_to root_path
    end
  end

  def log_access
    AccessLogInfo.create(
      user_nickname: current_user&.nickname,  # ユーザーネームがnilの場合はnil
      ip: request.remote_ip,                  # IPアドレス
      url: request.original_url,              # アクセスされたURL
      referer: request.referer,               # リファラー
      user_agent: request.user_agent,         # User-Agent
      method: request.request_method,         # HTTPメソッド
      status: response.status                 # レスポンスステータス
    )
  end
end
