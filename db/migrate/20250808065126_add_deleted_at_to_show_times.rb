class AddDeletedAtToShowTimes < ActiveRecord::Migration[8.0]
  def change
    add_column :show_times, :deleted_at, :datetime
    add_index :show_times, :deleted_at
  end
end
