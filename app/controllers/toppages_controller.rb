class ToppagesController < ApplicationController

  def index
    redirect_to dashboard_path if logged_in?
  end

  def about
  end

  def privacypolicy
  end

  def dashboard
    days_of_recent = 30
    num_of_announcement = 3
    num_of_next_lesson = 1
    

    if view_lessons?
      @lessons = current_user.attending_lessons.order(started_at: :asc).where('started_at > ?', Time.zone.now).limit(num_of_next_lesson)
    end

    @mynotes  = current_user.notes.order(updated_at: :desc).where('created_at > ?', Time.zone.now.ago(days_of_recent.days))

    if view_othernotes?
      @announcement = Note.where(announce: true).order(updated_at: :desc).first(num_of_announcement)
      @favorite_notes = current_user.favorite_notes.order(updated_at: :desc)
      @topliked_notes = Note.select('notes.*', 'count(likes.id) AS num_like').joins(:likes).group('notes.id')\
        .order('num_like desc').where('notes.created_at > ?', Time.zone.now.ago(days_of_recent.days))
      @following_notes = current_user.followings.map(&:latest_note).compact
    else
      
    end

  end
  
end
