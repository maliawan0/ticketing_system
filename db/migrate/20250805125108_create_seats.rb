class CreateSeats < ActiveRecord::Migration[8.0]
  def change
    create_table :seats do |t|
      t.string :seat_number
      t.integer :seat_type
      t.string :row
      t.integer :column
      t.references :screen, null: false, foreign_key: true

      t.timestamps
    end
  end
end
