class AddSlugToUniqueValues < ActiveRecord::Migration[7.0]
  def change
    add_column :unique_values, :slug, :string
    add_index :unique_values, :slug, unique: true
  end
end
