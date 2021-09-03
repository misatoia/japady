class LessonsController < ApplicationController
  before_action :require_user_logged_in
  before_action :require_auth_to_edit, only: [:new, :create, :update, :destroy]

  def index
    @user = current_user
    @lessons = []
    @title = 'すべての教室 / All lessons'
    if view_lessons?
      @lessons = Lesson
                 .joins(:user)
                 .where(users: { manager: true })
                 .order(started_at: :desc)
                 .page(params[:page]).per(10)

    else
      redirect_to dashboard_path
    end
  end

  def coming_lessons
    @user = current_user
    @lessons = []
    @title = '予定されている教室 / Coming lessons'

    if view_lessons?
      @lessons = Lesson
                 .coming_lessons
                 .joins(:user)
                 .where(users: { manager: true })
                 .page(params[:page]).per(10)

      render 'index'

    else
      redirect_to dashboard_path
    end
  end

  def new
    @lesson = current_user.lessons.new
    @title = '教室情報 作成 / New lesson'

    default_time = Time.zone.now
    @lesson.started_at = (default_time + 1.hours).strftime('%Y-%m-%d %H:00')
    @lesson.ended_at = (default_time + 2.hours).strftime('%H:00')

    render 'edit'
  end

  def edit
    @lesson = Lesson.find(params[:id])

    @title = '教室情報 編集 / Edit lesson'
    @managers = User
                .where(member: true, manager: true).pluck(:nickname, :id)
    @attendees = User
                 .where.not(id: Attendance.where(lesson_id: params[:id]).pluck(:user_id)).pluck(:nickname, :id)
    @attendance = Attendance.new

    @disabled = !((current_user == @lesson.user) || edit_otherlessons?)
  end

  def create
    @lesson = current_user.lessons.build(lesson_params)

    if @lesson.started_at < Time.zone.now
      flash.now[:danger] = '過去の日付では作成できません。'
      render 'edit'
    elsif @lesson.ended_at <= @lesson.started_at
      flash.now[:danger] = '終了時刻は開始時刻の後に設定してください。'
    elsif @lesson.save
      flash[:success] = '教室情報を作成しました。'
      redirect_to edit_lesson_path(@lesson)
    else
      flash.now[:danger] = '教室情報を作成できませんでした。'
      render 'edit'
    end
  end

  def update
    @lesson = Lesson.find(params[:id])

    if params[:create_duplication]
      duplicated_lesson = current_user.lessons.new(
        name: "#{@lesson.name} コピー",
        remarks: @lesson.remarks,
        started_at: @lesson.started_at,
        ended_at: @lesson.ended_at
      )
      duplicated_lesson.save
      flash[:success] = '教室情報を複製しました。'
      redirect_to edit_lesson_path duplicated_lesson

    else
      if @lesson.update(lesson_params)
        flash[:success] = '教室情報を更新しました。'
      else
        flash[:danger] = '教室情報を更新できませんでした。'
      end
      redirect_back(fallback_location: dashboard_path)
    end
  end

  def destroy
    @lesson = Lesson.find(params[:id])

    if @lesson.attendances.empty?
      @lesson.destroy
      flash[:success] = '教室情報を削除しました。'
      redirect_to lessons_path
    else
      # 出席者がいたら削除しない
      flash[:danger] = '教室情報を削除できませんでした。'
      redirect_back(fallback_location: dashboard_path)
    end
  end

  private

  def lesson_params
    params.require(:lesson).permit(:name, :remarks, :user_id, :started_at, :ended_at)
  end

  def require_auth_to_edit
    return if edit_lessons?

    redirect_back(fallback_location: dashboard_path)
  end
  

end
