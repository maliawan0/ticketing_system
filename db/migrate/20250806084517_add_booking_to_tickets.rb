class AddBookingToTickets < ActiveRecord::Migration[7.0]
  def change
    add_reference :tickets, :booking, foreign_key: true
  end
end
