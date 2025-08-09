class AddDeletedAtToCinemas < ActiveRecord::Migration[8.0]
  def change
    add_column :cinemas, :deleted_at, :datetime
    add_index :cinemas, :deleted_at
  end
end
