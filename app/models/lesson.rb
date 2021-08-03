class Lesson < ApplicationRecord
  belongs_to :user

  validates :name, presence: true, length: { maximum: 50 }

  validates :remarks, length: { maximum: 100 }

  has_many :attendances
  has_many :attendees, through: :attendances, source: :user, dependent: :destroy
    
  # Date of lesson
  def date_of_lesson
    self.started_at.strftime("%m月%d日(#{%w(日 月 火 水 木 金 土)[self.started_at.wday]}) %H:%M-") + self.ended_at.strftime("%H:%M")
  end

end
