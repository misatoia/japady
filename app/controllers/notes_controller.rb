class NotesController < ApplicationController
  before_action :require_user_logged_in

  def index
    # 権限によって表示するノートを変える
    # 検索によって与えられたパラメータによる絞りこみもここで行う
    if view_othernotes?
      notes_with_users = Note
                .includes(:user).references(:user)
                .where('users.member = true')
                .where.not(user_id: current_user.id)
      if (@keyword = params[:q])
        @notes = notes_with_users
                .where('content like ?', "%#{@keyword}%")
                .or(notes_with_users
                  .where('users.nickname like?', "%#{@keyword}%"))
                .order(created_at: :desc)
                .page(params[:page]).per(10)
      else
        @notes = notes_with_users.order(created_at: :desc)
                .page(params[:page]).per(10)
      end
    else
      redirect_to notes_user_path(current_user)
    end
  end

  def new
    @note = current_user.notes.new
    @title = '新規ノート作成 / New note'
    
    render 'edit'
  end

  def create
    @note = current_user.notes.build(note_params)

    if @note.save
      flash[:success] = 'ノートを作成しました。'
      redirect_to(edit_note_path(@note))
    else
      flash.now[:danger] = 'ノートを作成できませんでした。'
      render 'edit'
    end
  end

  def edit
    @note = Note.find(params[:id])
    @title = 'ノートの編集 / Edit note'

    # 権限チェック
    return if @note.user == current_user || edit_othernotes?

    redirect_back(fallback_location: dashboard_path)
  end

  def update
    @note = Note.find(params[:id])
    if @note.update(note_params)
      flash[:success] = 'ノートを更新しました。'
    else
      flash.now[:danger] = 'ノートを更新できませんでした。'
    end
    redirect_back(fallback_location: dashboard_path)
  end

  def destroy
    @note = Note.find(params[:id])

    # いいねがあったら削除しない
    if edit_othernotes? || (@note.user == current_user && @note.likes.empty?)
      @note.destroy
      flash[:success] = 'ノートを削除しました。'
      redirect_to notes_path
    else
      flash[:danger] = 'ノートを削除できませんでした。'
      redirect_back(fallback_location: dashboard_path)
    end
  end

  private

  def note_params
    params.require(:note).permit(:content, :user_id, :announce)
  end
end
