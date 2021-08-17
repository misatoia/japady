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

  def login_url_facebook
    state = SecureRandom.alphanumeric
    session[:facebook_state] = state

    endpoint = 'https://www.facebook.com/v11.0/dialog/oauth'
    params = {
      'client_id' => '534002854713007',
      'redirect_uri' => 'https://japady.herokuapp.com/auth/facebook/callback',
      'state' => state,
      'responce_type' => 'code',
      'scope' => 'email'
    }

    URI(endpoint + '?' + params.map { |k, v| "#{k}=#{v}" }.join('&'))
  end
end
