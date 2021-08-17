class ApplicationController < ActionController::Base
  include SessionsHelper

  private

  def require_user_logged_in
    return if logged_in?

    redirect_to login_url
  end

  def counts(user)
    @count_notes = user.notes.count
    @count_followings = user.followings.count
    @count_followers = user.followers.count
    @count_favorites = user.favorite_notes.count
  end
end
