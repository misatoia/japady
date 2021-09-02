class UsersController < ApplicationController
  before_action :require_user_logged_in, only: [:index, :show, :edit, :update, :destroy]

  def index
    @managers = User.none
    @users = User.none
    @guests = User.none
    @title = 'メンバー一覧'

    if view_lessons?
      all_managers = User.where(member: true, manager: true)

      managers_with_lesson = all_managers \
        .from(User\
          .joins(:lessons)\
          .where('lessons.started_at >= ?', Time.zone.now)\
          .group('users.id')\
          .select('users.*', 'min(lessons.started_at) AS next_lesson_started')\
          , :users)\
        .order('next_lesson_started ASC')
      
      managers_without_lesson = all_managers \
        .from(User\
          .where.not(id: managers_with_lesson.ids)\
          .left_outer_joins(:lessons)\
          .group('users.id')\
          .select('users.*', 'min(lessons.started_at) AS next_lesson_started')\
          , :users)

      @managers = Kaminari.paginate_array(managers_with_lesson + managers_without_lesson).page(params[:managers_page]).per(10)
      
      @managers_count = all_managers.size
    end

    if view_otherusers?
      all_users = User.where(member: true, manager: [nil, false])
      order_query_for_null = ENV['RAILS_ENV'] == 'production' ? ' NULLS LAST' : ''

      users_with_note = all_users\
        .left_outer_joins(:notes)\
        .group('users.id')\
        .select('users.*', 'max(notes.created_at) AS latest_note_created')\
        .order("latest_note_created DESC#{order_query_for_null}")
        
      @users = users_with_note.page(params[:users_page]).per(20)
      @users_count = all_users.size

      # メンバー管理権限ある場合
      if add_members?
        all_guests = User.where(member: [nil, false]).order(created_at: :desc)
        @guests = all_guests.page(params[:guests_page]).per(20)
        @guests_count = all_guests.size
      end

    # 権限が無ければ自分だけ
    else
      @users.push current_user

    end
  end

  def show
    @user = User.find(params[:id])
    if view_otherusers?
      @title = "#{@user.nickname}さんのプロフィール / #{@user.nickname}'s profile"

      @following_members = @user.followings.where(manager: [false, nil], member: true)
      @following_managers = @user.followings.where(manager: true, member: true)
      @authorizer = User.find_by(id: @user.authorized_by_id)

    elsif current_user != @user
      redirect_to current_user
    end
  end

  def new
    @user = User.new
  end

  def edit
    @user = User.find(params[:id])
    @title = "#{@user.nickname}さんのプロフィール編集"
    return if @user && (current_user == @user || edit_profiles?)

    redirect_to dashboard_path
  end

  def update
    @user = User.find(params[:id])

    # 管理者権限操作　→　管理者
    # 教室代表権限操作　→　管理者
    # メンバー権限操作　→　教室代表と管理者　教室代表による操作から管理者の権限操作は除く
    # プロフィールの編集　→　本人と管理者

    if !params[:member].nil?
      if !add_members?
        flash[:danger] = '承認操作ができません。'

      elsif params[:member] == 'true'
        @user.update(authorized_by_id: User.find(params[:authorized_by_id]).id, authorized_at: Time.zone.now, member: true)
        flash[:success] = "#{@user.nickname} さんを正規ユーザーとして承認しました。"
      else
        if !@user.admin
          # 管理者、教室代表の権限もfalseにする。
          @user.update(authorized_by_id: nil, authorized_at: nil, member: nil, manager: nil)
          flash[:success] = "#{@user.nickname} さんを非正規ユーザーにしました。"
        else
          flash[:warning] = "#{@user.nickname} さんは管理者であるため非正規ユーザーにはできません。"
        end
      end
      redirect_to @user

    elsif !params[:manager].nil?
      if !add_managers?
        flash[:danger] = '教室代表権限を操作できません。'
      else
        if @user.member
          @user.update(manager: params[:manager])
          flash[:primary] = "#{@user.nickname}さんの教室代表権限を#{@user.manager ? '付与' : '削除'}しました。"
        else
          flash[:warning] = "#{@user.nickname}さんは正規ユーザーではありません。"
        end
      end
      redirect_to edit_user_path(@user)

    elsif !params[:admin].nil?
      if (current_user == @user) || !add_admins?
        flash[:danger] = '管理権限を操作できません。'
      else
        if @user.member
          @user.update(admin: params[:admin])
          flash[:primary] = "#{@user.nickname}さんの管理者権限を#{@user.admin ? '付与' : '削除'}しました。"
        else
          flash[:warning] = "#{@user.nickname}さんは正規ユーザーではありません。"
        end
      end
      redirect_to edit_user_path(@user)

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
    if (current_user == @user) && !current_user.admin
      @user.destroy
      flash[:success] = '退会しました。'
      redirect_to root_path

    # 人のプロフィール、かつプロフィール編集権限を持ち、かつその人が管理者ではない。
    elsif (current_user != @user) && edit_profiles? && !@user.admin
      msg = []
      authorized_members = User.where(authorized_by_id: @user.id)
      authorized_members.each do |member|
        member.update(member: false)
        msg.push "#{member.id}: #{member.nickname}さん"
      end
      flash[:warning] = "【重要】#{msg.join('、')}のユーザー権限を一時的に無効にしました。正しいユーザーであることが確認できたらそれぞれのプロフィール画面で再度ユーザー承認をしてください。" if msg

      flash[:success] = "#{@user.nickname} さんのプロフィールを削除しました。"

      @user.destroy

      redirect_to users_path
    else
      flash[:danger] = "#{@user.nickname} さんのプロフィールを削除できませんでした。"
      redirect_to dashboard_path
    end
  end

  def create
    @user = User.new(user_params)
    if User.count.zero?
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
    @title = "#{@user.nickname}さんのノート" if @user != current_user

    if current_user == @user || view_othernotes?
      if (@keyword = params[:q])
        @notes = @user.notes.where('content like ?', "%#{@keyword}%")
                      .order(created_at: :desc).page(params[:page]).per(10)
      else
        @notes = @user.notes.order(created_at: :desc).page(params[:page]).per(10)
      end
    else
      redirect_to notes_user_path(current_user)
    end
  end

  def lessons
    @user = User.find(params[:id])
    if view_lessons?
      @title = "#{@user != current_user ? "#{@user.nickname}さんが" : ''}開催する（した）教室"
      @lessons = @user.lessons.order(started_at: :desc).page(params[:page]).per(10)
      render 'lessons/index'
    else
      flash[:danger] = '教室を閲覧する権限はありません'
      redirect_to dashboard_path
    end
  end

  def attended
    @user = User.find(params[:id])
    if view_attendedlessons? || @user == current_user
      @title = "#{@user != current_user ? "#{@user.nickname}さんが" : ''}これまで出席した教室"
      @lessons = @user.attending_lessons.where('started_at <= ?', Time.zone.now)
                      .order(started_at: :desc).page(params[:page]).per(10)
      render 'lessons/index'
    else
      flash[:danger] = '出席した教室を閲覧する権限がありません。'
      redirect_to @user
    end
  end

  private

  def user_params
    params.require(:user).permit(:name, :nickname, :email, :password, :password_confirmation, :area_of_residence, :purpose, :member, :manager, :admin, :authorized_by_id, :authorized_at)
  end
end
