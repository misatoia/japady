class SessionsController < ApplicationController
  def new; end

  def create
    email = params[:session][:email].downcase
    password = params[:session][:password]

    if login(email, password)
      redirect_to dashboard_path
    else
      flash.now[:danger] = 'ログインに失敗しました'
      render :new
    end
  end

  def destroy
    session[:user_id] = nil

    # facebook ログイン情報の削除
    delete_facebook_session

    flash[:success] = 'ログアウトしました'
    redirect_to root_url
  end

  private

  def login(email, password)
    @user = User.find_by(email: email)

    return false unless @user&.authenticate(password)

    session[:user_id] = @user.id
    true
  end

  def delete_facebook_session
    session[:fb_uid] = nil
    session[:fb_user_token] = nil
    session[:fb_token_expires_in] = nil
    session[:fb_state] = nil
    session[:fb_reauth] = nil
  end
end
