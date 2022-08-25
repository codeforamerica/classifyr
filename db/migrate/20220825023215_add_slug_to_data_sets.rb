class AddSlugToDataSets < ActiveRecord::Migration[7.0]
  def change
    add_column :data_sets, :slug, :string
    add_index :data_sets, :slug, unique: true
  end
end
