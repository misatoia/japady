module SessionsHelper
  def current_user
    @current_user ||= User.find_by(id: session[:user_id])
  end

  def admin?
    current_user.admin
  end

  def manager?
    current_user.manager
  end

  def member?
    current_user.member
  end

  def logged_in?
    !!current_user
  end

  def view_othernotes?
    member? || manager? || admin?
  end

  def edit_othernotes?
    admin?
  end
  
  def force_delete_notes?
    admin?
  end

  def make_announce?
    manager? || admin?
  end

  def view_lessons?
    member? || manager? || admin?
  end

  def edit_lessons?
    manager? || admin?
  end

  def edit_otherlessons?
    admin?
  end

  def force_delete_lessons?
    admin?
  end

  def view_otherusers?
    member? || manager? || admin?
  end

  def add_members?
    manager? || admin?
  end

  def edit_profiles?
    admin?
  end

  def view_attendedlessons?
    manager? || admin?
  end

  def add_managers?
    admin?
  end

  def add_admins?
    admin?
  end

  def delete_facebook_session
    session[:fb_uid] = nil
    session[:fb_user_token] = nil
    session[:fb_token_expires_in] = nil
    session[:fb_state] = nil
    session[:fb_reauth] = nil
  end

end
