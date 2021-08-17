class LikesController < ApplicationController
  before_action :require_user_logged_in

  def create
    note = Note.find(params[:note_id])
    current_user.like(note)
    flash[:success] = "#{note.user.nickname}さんのノートにいいね！をしました。"
    redirect_back(fallback_location: dashboard_path)
  end

  # 使うならボタンを設置しないと。。
  def destroy
    note = Like.find(params[:id]).note
    current_user.unlike(note)
    flash[:success] = "#{note.user.nickname}さんのノートからいいね！を外しました。"
    redirect_back(fallback_location: dashboard_path)
  end
end
