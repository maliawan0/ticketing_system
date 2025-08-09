class Screen < ApplicationRecord
  belongs_to :cinema
  has_many :show_times, class_name: 'ShowTime', dependent: :destroy
  has_many :movies, through: :show_times
  has_many :seats, dependent: :destroy

  validates :name, presence: true
  validates :seat_capacity, presence: true, numericality: { greater_than: 0 }

  # Helper methods
  def available_seats
    seats.where(available: true)
  end

  def seats_by_type(type)
    seats.by_type(type)
  end
end
