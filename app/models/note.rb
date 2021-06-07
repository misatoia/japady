class Note < ApplicationRecord
  belongs_to :user

  validates :content, presence: true, length: { maximum: 100 }

  has_many :favorites
  has_many :favoriting_users, through: :favorites, source: :user, dependent: :destroy

  has_many :likes
  has_many :liking_users, through: :likes, source: :user, dependent: :destroy
  

end
