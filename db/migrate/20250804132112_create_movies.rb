class CreateMovies < ActiveRecord::Migration[8.0]
  def change
    create_table :movies do |t|
      t.string :title
      t.string :category
      t.string :genre
      t.string :language
      t.integer :duration
      t.float :rating
      t.text :cast
      t.text :description
      t.string :image_url

      t.timestamps
    end
  end
end
