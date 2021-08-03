class FavoritesController < ApplicationController
  before_action :require_user_logged_in

  def create
    note = Note.find(params[:note_id])
    current_user.favorite(note)
    flash[:success] = "#{note.user.nickname}さんのノートをお気に入りに追加しました。"
    redirect_back(fallback_location: dashboard_path)
  end

  def destroy
    note = Favorite.find(params[:id]).note
    current_user.unfavorite(note)
    flash[:success] = "#{note.user.nickname}さんのノートをお気に入りから外しました。"
    redirect_back(fallback_location: dashboard_path)

  end
end
