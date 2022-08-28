class AddCompletionPercentToDataSet < ActiveRecord::Migration[7.0]
  def change
    add_column :data_sets, :completion_percent, :integer, default: 0
    add_column :data_sets, :completed_unique_values, :integer, default: 0
    add_column :data_sets, :total_unique_values, :integer, default: 0
  end
end
