class ToppagesController < ApplicationController
  def index
    redirect_to dashboard_path if logged_in?
  end

  def about; end

  def privacypolicy; end

  def dashboard
    @days_of_recent = 30
    num_of_announcement = 3
    num_of_next_lesson = 1
    @num_of_top_likes = 5

    @title = 'ダッシュボード'

    if view_lessons?
      @lessons = current_user.attending_lessons \
                              .coming_lessons \
                              .joins(:user) \
                              .where(users: { manager: true }) \
                              .limit(num_of_next_lesson)
    end

    if view_othernotes?
      notes_with_users = Note.includes(:user).references(:user).where('users.member = true')
                
      @announcement = notes_with_users.where(announce: true).order(updated_at: :desc).first(num_of_announcement)
      @favorite_notes = current_user.favorite_notes.order(updated_at: :desc)
      @topliked_notes = notes_with_users\
                          .from(Note\
                            .joins(:likes)\
                            .group('notes.id')\
                            .select('notes.*', 'count(likes.id) AS num_like')\
                            , :notes)\
                          .order('num_like desc')\
                          .where('notes.created_at > ?', Time.zone.now.ago(@days_of_recent.days))\
                          .limit(@num_of_top_likes)

      @following_notes = current_user.followings.map(&:latest_note).compact
    else
      @favorite_notes = current_user.favorite_notes.where(user_id: current_user.id).order(updated_at: :desc)
    end

    @mynotes = current_user.notes.order(updated_at: :desc).where('created_at > ?', Time.zone.now.ago(@days_of_recent.days))
  end
end
