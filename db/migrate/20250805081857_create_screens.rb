class CreateScreens < ActiveRecord::Migration[8.0]
  def change
    create_table :screens do |t|
      t.references :cinema, null: false, foreign_key: true
      t.string :name
      t.integer :seat_capacity

      t.timestamps
    end
  end
end
