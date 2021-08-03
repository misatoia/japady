class Note < ApplicationRecord
  belongs_to :user

  validates :content, presence: true, length: { maximum: 100 }

  has_many :favorites
  has_many :favoriting_users, through: :favorites, source: :user, dependent: :destroy

  has_many :likes
  has_many :liking_users, through: :likes, source: :user, dependent: :destroy


  # Date of note
  def date_of_note
    self.created_at.strftime("%m月%d日(#{%w(日 月 火 水 木 金 土)[self.created_at.wday]}) %H:%M")
  end


end
