class SessionsController < ApplicationController
  def new
  
  end

  def create
    email = params[:session][:email].downcase
    password = params[:session][:password]
    
    if login(email, password)
      flash[:success] = 'ログインに成功しました。'
      redirect_to @user
    else
      flash.now[:danger] = 'ログインに失敗しました'
      render :new
    end
  end

  def destroy
    session[:user_id] = nil
    flash[:success] = 'ログアウトしました'
    redirect_to root_url

  end

  def test_request
    require 'net/http'

    api_base_url='https://app.rakuten.co.jp/services/api/IchibaItem/Search/20170706'
    
    # 送信するパラメータを設定
    keyword = 'Ruby'
    params = {
      'keyword'       => URI.encode(keyword),
      'format'        => 'json',
      'applicationId' => '1052039530918897721',
      'hits'          => 10,
      'imageFlag'     => 1
    }
    
    # パラメータを組み立ててURLの後ろに `?keyword=#{keyword}&format=json&...`という形にしてURLとして扱えるようにする
    uri = URI(api_base_url + '?' + params.map{|k,v| "#{k}=#{v}"}.join('&'))
    
    # Rubyの標準ライブラリ処理を用いてHTTPのGETリクエストを送る
    response_json = Net::HTTP.get(uri)
    
    # Rubyの標準ライブラリ処理を用いて受け取ったJSONをパース（分解）してRubyの処理として使えるようにする
    response_data = JSON.parse(response_json)
    
    # 取得したデータを10件まで表示
    @result = response_data['Items'].first(10)

  end


  # facebookからの認可コード受け取り
  def facebook_callback
    @params = params

    # パラメータ解釈
    
    # 得られた認可コードでアクセストークンを要求
    
    # パラメータ解釈

    # 得られたアクセストークンでユーザー情報を要求
    
    # パラメータ解釈
    
    # データベースにUIDを格納

    # セッションを開始
    
  end
  
  private
  
  def login(email, password)
    @user = User.find_by(email: email)
    if @user && @user.authenticate(password)
      session[:user_id] = @user.id
      return true
      
    else
      #ログイン失敗
      return false
    end
  end
  
end
