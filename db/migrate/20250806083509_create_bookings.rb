class CreateBookings < ActiveRecord::Migration[8.0]
  def change
    create_table :bookings do |t|
      t.references :bookable, polymorphic: true, null: false
      t.string :booking_reference
      t.integer :status
      t.decimal :total_price, precision: 10, scale: 2, default: 0.0


      t.timestamps
    end
  end
end
