class CreateRoles < ActiveRecord::Migration[7.0]
  def change
    create_table :roles do |t|
      t.string :name, null: false

      t.timestamps null: false
    end

    add_index :roles, :name, unique: true

    add_reference :users, :role, index: true
  end
end
