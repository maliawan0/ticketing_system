class Booking < ApplicationRecord
  belongs_to :user
  belongs_to :bookable, polymorphic: true
  has_many :tickets, dependent: :nullify

  enum :status, {
    pending: 0,
    confirmed: 1,
    cancelled: 2,
    refunded: 3
  }

  validates :booking_reference, presence: true, uniqueness: true
  validates :status, presence: true

  before_validation :generate_reference, on: :create

  # Generate a unique booking reference if not provided
  def generate_reference
    self.booking_reference ||= "BK#{SecureRandom.hex(4).upcase}"
  end

  # Calculate total price from all associated tickets
  def calculate_total_price(base_price = 10.0)
    update!(
      total_price: tickets.map { |ticket| ticket.price(base_price) }.sum.round(2)
    )
  end

  # Mark booking as confirmed
  def confirm!
    update!(status: :confirmed)
  end

  # Cancel booking and unlock tickets
  def cancel!
    tickets.each(&:unlock!)
    update!(status: :cancelled)
  end

  # Refund booking (business logic can differ)
  def refund!
    tickets.each(&:unlock!)
    update!(status: :refunded)
  end

  # Return number of tickets in booking
  def total_seats
    tickets.count
  end

  # Useful for UI/debugging
  def display_info
    "#{booking_reference} - #{status.titleize} - ₹#{total_price} - #{bookable_type} ##{bookable_id}"
  end
end
