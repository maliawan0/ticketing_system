class Seat < ApplicationRecord
  belongs_to :screen

  enum :seat_type, { standard: 0, premium: 1, vip: 2 }

  validates :seat_number, presence: true, uniqueness: { scope: :screen_id }
  validates :row, presence: true
  validates :column, presence: true, numericality: { greater_than: 0 }
  validates :seat_type, presence: true

  # Scopes for easy querying
  scope :by_type, ->(type) { where(seat_type: type) }
  scope :by_row, ->(row) { where(row: row) }
  scope :ordered, -> { order(:row, :column) }

  # Helper methods
  def seat_type_price_multiplier
    case seat_type
    when 'standard'
      1.0
    when 'premium'
      1.5
    when 'vip'
      2.0
    else
      1.0
    end
  end

  def display_name
    "#{seat_number} (#{seat_type.titleize})"
  end
end
