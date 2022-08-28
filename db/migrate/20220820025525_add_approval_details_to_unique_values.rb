class AddApprovalDetailsToUniqueValues < ActiveRecord::Migration[7.0]
  def change
    add_column :unique_values, :approved_at, :datetime
    add_column :unique_values, :review_required, :boolean, default: false
    add_column :unique_values, :auto_reviewed_at, :datetime
  end
end
