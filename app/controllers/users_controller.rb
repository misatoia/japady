class UsersController < ApplicationController
  before_action :require_user_logged_in, only: [:index, :show, :edit, :update, :destroy]

  def index

    # 教室代表＝レッスン
    if view_lessons?
      @managers = User.where(manager: true).order(id: :desc).page(params[:page]).per(5)
    end

    # メンバー管理権限ある場合
    if add_members?
      @users = User.where(member: true).order(id: :desc).page(params[:page]).per(10)
      @guests = User.where(member: [nil, false]).order(created_at: :desc).page(params[:page]).per(10)

    # 他のメンバーの閲覧権限がある場合
    elsif view_otherusers?
      @users = User.where(member: true).order(id: :desc).page(params[:page]).per(10)

    # 権限が無ければ自分だけ
    else
      @users = []
      @users.push current_user

    end

  end


  def show
    @user = User.find(params[:id])
    if view_otherusers?

      @following_members = @user.followings.where(manager: [false, nil], member: true)
      @following_managers = @user.followings.where(manager: true, member: true)
    
      counts(@user)
    else
      if current_user != @user
        redirect_to current_user
      end
    end

  end

  def new
    @user = User.new

  end

  def edit
    @user = User.find(params[:id])
    unless (current_user ==  @user) || edit_profiles?
      redirect_to dashboard_path
    end
  end

  def update
    @user = User.find(params[:id])

    # 管理者権限操作　→　管理者
    # 教室代表権限操作　→　管理者
    # メンバー権限操作　→　教室代表と管理者　教室代表による操作から管理者の権限操作は除く
    # プロフィールの編集　→　本人と管理者

    if params[:admin].present?
      if (current_user == @user) || !add_admins?
        flash[:danger] = '管理権限を操作できません。'
      else
        if @user.member
          @user.admin = params[:admin]
          @user.save
          flash[:primary] = "#{@user.nickname}さんの管理者権限を #{@user.admin} にしました。"
        else
          flash[:warning] = "#{@user.nickname}さんは正規ユーザーではありません。"
        end
      end
      redirect_to edit_user_path(@user)

    elsif params[:manager].present?
      if !add_managers?
        flash[:danger] = '教室代表権限を操作できません。'
      else
        if @user.member
          @user.manager = params[:manager]
          @user.save
          flash[:primary] = "#{@user.nickname}さんの教室代表権限を #{@user.manager} にしました。"
        else
          flash[:warning] = "#{@user.nickname}さんは正規ユーザーではありません。"
        end
      end
      redirect_to edit_user_path(@user)

    elsif params[:authorized_by_id].present?
      if !add_members?
        flash[:danger] = '承認操作ができません。'

      elsif params[:authorized_by_id].empty?
        if !(@user.admin)
          @user.authorized_by_id = nil
          @user.authorized_at = nil
          @user.member = false
          @user.manager = false
          @user.save
          flash[:success] = "#{@user.nickname} さんを非正規ユーザーにしました。"
        else
          flash[:warning] = "#{@user.nickname} さんは管理者であるため非正規ユーザーにはできません。"
        end
        # 管理者、教室代表の権限もfalseにする。
      else
        @user.authorized_by_id = User.find(params[:authorized_by_id]).id
        @user.authorized_at = Time.zone.now
        @user.member = true
        @user.save
        flash[:success] = "#{@user.nickname} さんを正規ユーザーとして承認しました。"
      end
      redirect_to @user

    else
      if @user.update(user_params)
        flash[:success] = 'ユーザプロフィールを更新しました。'
        redirect_to edit_user_path(@user)
      else
        flash.now[:danger] = 'ユーザプロフィールの更新に失敗しました。'
        render :edit
      end
    end


  end

  def destroy
    @user = User.find(params[:id])

    # 自分のプロフィール、かつ自分が管理者ではない。
    case1 = ((current_user ==  @user ) && !current_user.admin)

    # 人のプロフィール、かつプロフィール編集権限を持ち、かつその人が管理者ではない。
    case2 = ((current_user !=  @user ) && edit_profiles? && !@user.admin)

    if case1 || case2
      @user.destroy
      flash[:success] = '退会しました。'
      redirect_to root_path
    else
      flash[:danger] = "#{@user.nickname} さんのプロフィールを削除できませんでした。"
      redirect_to dashboard_path
    end
  end

  def create
    @user = User.new(user_params)
    if User.count == 0
      @user.member = true
      @user.manager = true
      @user.admin = true
    end    
    
    if @user.save
      flash[:success] = 'ユーザーを登録しました。'
      # begin session
      session[:user_id] = @user.id
      redirect_to @user
    else
      flash.now[:danger] = 'ユーザの登録に失敗しました。'
      render :new
    end
  end
  
  def notes
    # このアクションでは自分のノート表示のみ
    @user = User.find(params[:id])
    
    # 自分以外のノートも見られるようにする
    if current_user == @user || view_othernotes?
      if @keyword = params[:q]
        @notes = @user.notes.where("content like ?", "%#{@keyword}%")
          .order(id: :desc).page(params[:page]).per(10)
      else
        @notes = @user.notes.order(id: :desc).page(params[:page]).per(10)
      end
    else
      redirect_to notes_user_path(current_user)
    end        

  end
  
  def attended
    @user = User.find(params[:id])
    if view_attendedlessons? || @user == current_user
      @lessons = @user.attending_lessons.where('started_at <= ?', Time.zone.now)
        .order(started_at: :desc).page(params[:page]).per(10)
    else
      flash[:danger] = '[デバッグ確認]出席した教室を閲覧する権限はない'
      redirect_to @user
    end

  end

  private
  
  def user_params
      params.require(:user).permit(:name, :nickname, :email, :password, :password_confirmation, :area_of_residence, :purpose, :member, :manager, :admin, :authorized_by_id, :authorized_at)
  end

end
