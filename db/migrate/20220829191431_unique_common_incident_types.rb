class UniqueCommonIncidentTypes < ActiveRecord::Migration[7.0]
  def change
    # Remove duplicate records before adding the unique key.
    keepers = CommonIncidentType.select('MIN(id) AS id')
                                .group(:standard, :version, :code)
    CommonIncidentType.excluding(keepers).destroy_all

    add_index :common_incident_types, [:standard, :version, :code], unique: true
  end
end
