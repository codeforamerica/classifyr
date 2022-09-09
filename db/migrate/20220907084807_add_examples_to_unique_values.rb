class AddExamplesToUniqueValues < ActiveRecord::Migration[7.0]
  def change
    add_column :unique_values, :examples, :json, default: [], null: false
  end
end
