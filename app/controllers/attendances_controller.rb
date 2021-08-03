class AttendancesController < ApplicationController
  before_action :require_user_logged_in

  def create
    if view_lessons?
      lesson = Lesson.find(params[:lesson_id])

      if edit_lessons? && params[:attendance].present? && params[:attendance][:email].present?
        user = User.find_by(email: params[:attendance][:email])
        if user.present? && user.member
          user.attend(lesson)
          flash[:success] = "#{lesson.name}のレッスンの参加予定者に#{user.nickname}さんを登録しました。"
        else
          flash[:warning] = "#{params[:attendance][:email]}で登録している正規ユーザーを確認できませんでした。"
        end
      else
        current_user.attend(lesson)
        flash[:success] = "#{lesson.name}のレッスンの参加予定者に登録しました。"
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

end
