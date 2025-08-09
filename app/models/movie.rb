class Movie < ApplicationRecord
    # Soft delete: hides deleted records by default
    default_scope { where(deleted_at: nil) }
  
    scope :with_deleted, -> { unscope(where: :deleted_at) }
    scope :only_deleted, -> { with_deleted.where.not(deleted_at: nil) }

    def self.ransackable_attributes(auth_object = nil)
        %w[title genre]
      end

    def soft_delete
      update(deleted_at: Time.current)
    end
  
    def restore
      update(deleted_at: nil)
    end
  
    def destroy
      soft_delete
    end
  
    has_many :show_times, class_name: 'ShowTime', dependent: :destroy
    has_many :screens, through: :show_times
    
    validates :title, :category, :genre, :language, :duration, :rating, presence: true
    validates :rating, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 10 }
    validates :duration, numericality: { only_integer: true, greater_than: 0 }

    
    paginates_per 10

  end
  