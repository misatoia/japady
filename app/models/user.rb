class User < ApplicationRecord

    before_save { self.email.downcase! }
    validates :nickname, presence: true, length:{ maximum:50 }
    validates :name, length:{ maximum:50 }
    validates :email, presence: true, length:{ maximum:255 },
        format: { with: /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i },
        uniqueness: { case_sensitive: false }
    validates :area_of_residence, length:{ maximum:100 }
    validates :purpose, length:{ maximum:1000 }

    has_secure_password

    # as the owner
    has_many :lessons, dependent: :destroy
    has_many :notes, dependent: :destroy


    # as an attendee
    has_many :attendances
    has_many :attending_lessons, through: :attendances, source: :lesson, dependent: :destroy
    
    def snslogin?
#      !self.uid.empty?
      !self.nickname.empty?
    end
    
    def attend(lesson)
        self.attendances.find_or_create_by(lesson_id: lesson.id)
    end
        
    def unattend(lesson)
        attendance = self.attendances.find_by(lesson_id: lesson.id)
        attendance.destroy if attendance
    end
    
    def attending?(lesson)
        self.attending_lessons.include?(lesson)
    end


    # as a follower
    has_many :relationships
    has_many :followings, through: :relationships, source: :follow, dependent: :destroy
    
    # as a followed one
    has_many :reverses_of_relationship, class_name: 'Relationship', foreign_key: 'follow_id'
    has_many :followers, through: :reverses_of_relationship, source: :user, dependent: :destroy

    def follow(other_user)
        unless self == other_user
            self.relationships.find_or_create_by(follow_id: other_user.id)
        end
    end
    
    def unfollow(other_user)
        relationship = self.relationships.find_by(follow_id: other_user.id)
        relationship.destroy if relationship
    end

    def following?(other_user)
        self.followings.include?(other_user)
    end
    
    def feed_notes
        Notes.where(user_id: self.following_ids + [self.id])
    end

    
    # favorite notes
    has_many :favorites
    has_many :favorite_notes, through: :favorites, source: :note, dependent: :destroy

    def favorite(note)
        self.favorites.find_or_create_by(note_id: note.id)
    end
        
    def unfavorite(note)
        favorite = self.favorites.find_by(note_id: note.id)
        favorite.destroy if favorite
    end
    
    def favoriting?(note)
        self.favorite_notes.include?(note)
    end

    
    # liking notes
    has_many :likes
    has_many :liking_notes, through: :likes, source: :note, dependent: :destroy

    def like(note)
        self.likes.find_or_create_by(note_id: note.id)
    end
        
    def unlike(note)
        like = self.likes.find_by(note_id: note.id)
        like.destroy if like
    end
    
    def liking?(note)
        self.liking_notes.include?(note)
    end
    
    # Note
    def latest_note
        self.notes.order(created_at: :desc).first
    end

    def latest_announcement
        self.notes.where(announce: true).order(updated_at: :desc).first
    end

    # Lesson
    def next_lesson
        self.lessons.where("started_at >= ?", Time.zone.now).order(started_at: :asc).first
    end
    
    
    def me?(user)
      self == user
    end

end
