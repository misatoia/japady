module LessonsHelper

  def min(datetime)
    (@current_time ||= Time.zone.now) < datetime ? @current_time : datetime
  end

end
