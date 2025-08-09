class CreateCinemas < ActiveRecord::Migration[8.0]
  def change
    create_table :cinemas do |t|
      t.string :name
      t.references :area, null: false, foreign_key: true

      t.timestamps
    end
  end
end
