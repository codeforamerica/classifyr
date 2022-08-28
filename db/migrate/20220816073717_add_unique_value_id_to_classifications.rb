class AddUniqueValueIdToClassifications < ActiveRecord::Migration[7.0]
  def change
    add_reference :classifications, :unique_value, index: true
    add_column :unique_values, :classifications_count, :integer, default: 0
  end
end
