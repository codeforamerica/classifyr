class RenameCommonIncidentTypesVersionToCodeVersion < ActiveRecord::Migration[7.0]
  def change
    remove_index :common_incident_types, name: "index_common_incident_types_on_standard_and_version_and_code"
    rename_column :common_incident_types, :version, :code_version
    add_index :common_incident_types, [:standard, :code_version, :code],
              name: "index_common_incident_types_on_standard_and_version_and_code"
  end
end
