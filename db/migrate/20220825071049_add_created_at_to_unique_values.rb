class AddCreatedAtToUniqueValues < ActiveRecord::Migration[7.0]
  def change
    add_timestamps :unique_values, default: -> { "now()" }, null: false
  end
end
