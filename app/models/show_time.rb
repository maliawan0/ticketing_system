class ShowTime < ApplicationRecord
  # Soft delete: hides deleted records by default
  default_scope { where(deleted_at: nil) }

  scope :with_deleted, -> { unscope(where: :deleted_at) }
  scope :only_deleted, -> { with_deleted.where.not(deleted_at: nil) }

  def soft_delete
    update(deleted_at: Time.current)
  end

  def restore
    update(deleted_at: nil)
  end

  def destroy
    soft_delete
  end

  belongs_to :movie
  belongs_to :screen
  has_many :tickets, dependent: :destroy
  has_many :seats, through: :tickets


  def self.ransackable_attributes(auth_object = nil)
    ["id", "movie_id", "start_time", "end_time", "screen_id", "created_at", "updated_at"]
  end

  


  validates :start_time, presence: true
  validates :end_time, presence: true
  validate  :end_time_after_start_time
  validate  :no_overlapping_show_times

  scope :upcoming, -> { where('start_time > ?', Time.current) }
  scope :today, -> { where(start_time: Time.current.beginning_of_day..Time.current.end_of_day) }
  scope :by_movie, ->(movie) { where(movie: movie) }
  scope :by_screen, ->(screen) { where(screen: screen) }

  def available_seats
    tickets.available.includes(:seat)
  end

  def booked_seats
    tickets.booked.includes(:seat)
  end

  def locked_seats
    tickets.locked.includes(:seat)
  end

  def reserved_seats
    tickets.reserved.includes(:seat)
  end

  def available_seats_by_type(seat_type)
    tickets.available.by_seat_type(seat_type).includes(:seat)
  end

  def total_seats
    tickets.count
  end

  def available_seats_count
    tickets.available.count
  end

  def booked_seats_count
    tickets.booked.count
  end

  def occupancy_percentage
    return 0 if total_seats.zero?
    ((booked_seats_count.to_f / total_seats) * 100).round(2)
  end

  def is_full?
    available_seats_count.zero?
  end

  def has_available_seats?
    available_seats_count > 0
  end

  def display_info
    "#{movie.title} at #{screen.name} - #{start_time.strftime('%Y-%m-%d %H:%M')}"
  end

  private

  def end_time_after_start_time
    return if start_time.blank? || end_time.blank?
    if end_time <= start_time
      errors.add(:end_time, "must be after the start time")
    end
  end

  def no_overlapping_show_times
    return if start_time.blank? || end_time.blank?

    overlapping = ShowTime.where(screen_id: screen_id)
                          .where.not(id: id)
                          .where("start_time < ? AND end_time > ?", end_time, start_time)
    if overlapping.exists?
      errors.add(:base, "ShowTime overlaps with another show on the same screen")
    end
  end
end
