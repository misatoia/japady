class LessonsController < ApplicationController
  before_action :require_user_logged_in
  
  def index
    if  view_lessons?
      @lessons = Lesson
      .where("started_at >= ?", Time.zone.now).order(started_at: :asc)
      .order(started_at: :desc).page(params[:page]).per(10)
    else
      redirect_to dashboard_path
    end
  end

  def new
    @lesson = current_user.lessons.new

    default_time = Time.zone.now
    @lesson.started_at = (default_time + 60*60).strftime(("%Y-%m-%d %H:00"))
    @lesson.ended_at = (default_time + 2*60*60).strftime("%H:00")

    render 'edit'
  end

  def edit
    @lesson = Lesson.find(params[:id])
    # 権限チェック
    unless @lesson.user = current_user || edit_lessons?
      redirect_back(fallback_location: dashboard_path)
    end

  end

  def create
    @lesson = current_user.lessons.build(lesson_params)

    if @lesson.save
      flash[:success] = 'レッスン情報を作成しました。'
      redirect_to edit_lesson_path(@lesson)
    else
      flash.now[:danger] = 'レッスン情報を作成できませんでした。'
      render 'edit'
    end

  end

  def update
    @lesson = Lesson.find(params[:id])

    if @lesson.update(lesson_params)
      flash[:success] = 'レッスン情報を更新しました。'
    else
      flash.now[:danger] = 'レッスン情報を更新できませんでした。'
    end
    redirect_back(fallback_location: dashboard_path)
  end

  def destroy
    @lesson = Lesson.find(params[:id])

    # 出席者がいたら削除しない
    if edit_lessons? || (@lesson.user == current_user && @lesson.attendances.empty?)
      @lesson.destroy
      flash[:success] = 'レッスン情報を削除しました。'
      redirect_to lessons_path
    else
      flash[:danger] = 'レッスン情報を削除できませんでした。'
      redirect_back(fallback_location: dashboard_path)
    end
  end

  private
  
  def lesson_params
      params.require(:lesson).permit(:name, :remarks, :user_id, :started_at, :ended_at)
  end
  
end
