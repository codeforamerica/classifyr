class AddUniqueIndexToClassifications < ActiveRecord::Migration[7.0]
  def change
    add_index :classifications, [:user_id, :unique_value_id], unique: true
  end
end
