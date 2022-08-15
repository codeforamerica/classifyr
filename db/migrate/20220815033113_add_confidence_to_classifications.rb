class AddConfidenceToClassifications < ActiveRecord::Migration[7.0]
  def change
    add_column :classifications, :confidence_rating, :integer
    add_column :classifications, :confidence_reasoning, :text
  end
end
