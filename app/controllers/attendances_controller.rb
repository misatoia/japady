class AttendancesController < ApplicationController
  before_action :require_user_logged_in

  def create
    if view_lessons?

      if params[:lesson_id] && (lesson = Lesson.find(params[:lesson_id]))
        current_user.attend(lesson)
        flash[:success] = "#{lesson.name}の教室の参加予定者に登録しました。"
      elsif edit_lessons? && (attendance = Attendance.new(attendance_params))
        if attendance.save
          flash[:success] = "#{attendance.lesson.name}の教室の参加予定者に#{attendance.user.nickname}さんを登録しました。"
        else
          flash[:warning] = '教室の参加登録ができませんでした。'
        end
      end
      redirect_back(fallback_location: dashboard_path)
    else
      redirect_to dashboard_path
    end
  end

  def destroy
    if view_lessons?
      lesson = Attendance.find(params[:id]).lesson
      if edit_lessons?
        user = Attendance.find(params[:id]).user
        user.unattend(lesson)
        flash[:success] = "#{lesson.name}のレッスンの#{user.nickname}さんの参加予定を取り消しました。"
      else
        current_user.unattend(lesson)
        flash[:success] = "#{lesson.name}のレッスンの参加予定を取り消しました。"
      end
      redirect_back(fallback_location: dashboard_path)
    else
      redirect_to dashboard_path
    end
  end

  private

  def attendance_params
    params.require(:attendance).permit(:user_id, :lesson_id)
  end
end
