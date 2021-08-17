class User < ApplicationRecord
  before_save { email.downcase! }
  validates :nickname, presence: true, length: { maximum: 50 }
  validates :name, length: { maximum: 50 }
  validates :email, presence: true, length: { maximum: 255 },
                    format: { with: /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i },
                    uniqueness: { case_sensitive: false }
  validates :area_of_residence, length: { maximum: 100 }
  validates :purpose, length: { maximum: 1000 }

  has_secure_password

  # as the owner
  has_many :lessons, dependent: :destroy
  has_many :notes, dependent: :destroy

  # as an attendee
  has_many :attendances, dependent: :destroy
  has_many :attending_lessons, through: :attendances, source: :lesson, dependent: :destroy

  def snslogin?
    uid?
  end

  def attend(lesson)
    attendances.find_or_create_by(lesson_id: lesson.id)
  end

  def unattend(lesson)
    attendance = attendances.find_by(lesson_id: lesson.id)
    attendance&.destroy
  end

  def attending?(lesson)
    attending_lessons.include?(lesson)
  end

  # as a follower
  has_many :relationships, dependent: :destroy
  has_many :followings, through: :relationships, source: :follow, dependent: :destroy

  # as a followed one
  has_many :reverses_of_relationship, class_name: 'Relationship', foreign_key: 'follow_id', dependent: :destroy, inverse_of: :user
  has_many :followers, through: :reverses_of_relationship, source: :user, dependent: :destroy

  def follow(other_user)
    return if self == other_user

    relationships.find_or_create_by(follow_id: other_user.id)
  end

  def unfollow(other_user)
    relationship = relationships.find_by(follow_id: other_user.id)
    relationship&.destroy
  end

  def following?(other_user)
    followings.include?(other_user)
  end

  def feed_notes
    Notes.where(user_id: following_ids + [id])
  end

  # favorite notes
  has_many :favorites, dependent: :destroy
  has_many :favorite_notes, through: :favorites, source: :note, dependent: :destroy

  def favorite(note)
    favorites.find_or_create_by(note_id: note.id)
  end

  def unfavorite(note)
    favorite = favorites.find_by(note_id: note.id)
    favorite&.destroy
  end

  def favoriting?(note)
    favorite_notes.include?(note)
  end

  # liking notes
  has_many :likes, dependent: :destroy
  has_many :liking_notes, through: :likes, source: :note, dependent: :destroy

  def like(note)
    likes.find_or_create_by(note_id: note.id)
  end

  def unlike(note)
    like = likes.find_by(note_id: note.id)
    like&.destroy
  end

  def liking?(note)
    liking_notes.include?(note)
  end

  # Note
  def latest_note
    notes.order(created_at: :desc).first
  end

  def latest_announcement
    notes.where(announce: true).order(updated_at: :desc).first
  end

  # Lesson
  def next_lesson
    lessons.where('started_at >= ?', Time.zone.now).order(started_at: :asc).first
  end
end
