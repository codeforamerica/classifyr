class AddHumanizedNotesToCommonIncidentTypes < ActiveRecord::Migration[7.0]
  def change
    add_column :common_incident_types, :humanized_notes, :text
  end
end
