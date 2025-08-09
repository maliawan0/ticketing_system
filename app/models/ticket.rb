class Ticket < ApplicationRecord
  belongs_to :show_time
  belongs_to :seat
  belongs_to :booking, optional: true  # <-- Add this


  enum :status, {
    available: 0,
    locked: 1,
    booked: 2,
    reserved: 3
  }

  validates :show_time, presence: true
  validates :seat, presence: true
  validates :status, presence: true
  validates :seat, uniqueness: { scope: :show_time_id, message: "can only be mapped once per show time" }

  scope :available, -> { where(status: :available) }
  scope :booked, -> { where(status: :booked) }
  scope :locked, -> { where(status: :locked) }
  scope :reserved, -> { where(status: :reserved) }
  scope :by_show_time, ->(show_time) { where(show_time: show_time) }
  scope :by_seat_type, ->(seat_type) { joins(:seat).where(seats: { seat_type: seat_type }) }

  def available?
    status == 'available'
  end

  def locked?
    status == 'locked'
  end

  def booked?
    status == 'booked'
  end

  def reserved?
    status == 'reserved'
  end

  def lock!(booking_ref = nil)
    update!(
      status: :locked,
      locked_at: Time.current,
      booking_reference: booking_ref
    )
  end

  def unlock!
    update!(
      status: :available,
      locked_at: nil,
      booking_reference: nil
    )
  end

  def book!(booking_ref = nil)
    update!(
      status: :booked,
      locked_at: nil,
      booking_reference: booking_ref
    )
  end

  def reserve!(booking_ref = nil)
    update!(
      status: :reserved,
      locked_at: nil,
      booking_reference: booking_ref
    )
  end

  def lock_expired?
    locked? && locked_at && locked_at < 15.minutes.ago
  end

  def unlock_if_expired!
    unlock! if lock_expired?
  end

  def display_info
    "#{seat.display_name} - #{status.titleize}"
  end

  def price(base_price = 10.0)
    base_price * seat.seat_type_price_multiplier
  end
  # app/models/ticket.rb
  def full_booking_info
    {
      location: seat.screen.cinema.area.location.name,
      area: seat.screen.cinema.area.name,
      cinema: seat.screen.cinema.name,
      screen: seat.screen.name,
      seat_number: seat.seat_number,
      seat_type: seat.seat_type,
      row: seat.row,
      column: seat.column,
      status: status
    }
  end
end
