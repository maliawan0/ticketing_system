class CreateShowTimeSeats < ActiveRecord::Migration[8.0]
  def change
    create_table :show_time_seats do |t|
      t.references :show_time, null: false, foreign_key: true
      t.references :seat, null: false, foreign_key: true
      t.integer :status
      t.datetime :locked_at
      t.string :booking_reference

      t.timestamps
    end
  end
end
