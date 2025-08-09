class RenameShowTimeSeatsToTickets < ActiveRecord::Migration[7.0]
  def change
    rename_table :show_time_seats, :tickets
  end
end
