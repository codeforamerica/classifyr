require 'csv'

ds = DataSet.create!(
                       {title: "Burlington, VT Police Incidents", data_link: "https://data.burlingtonvt.gov/explore/?refine.theme=Public+Safety&disjunctive.theme&disjunctive.publisher&disjunctive.keyword&sort=modified", documentation_link: "https://data.burlingtonvt.gov/explore/dataset/police-incidents-2021/information/", api_links: "https://data.burlingtonvt.gov/explore/dataset/police-incidents-2021/api/", source: "Burlington Police Department; contact  jlarson@burlingtonvt.gov", exclusions: "\"the most sensitive types of calls,\" not specified", format: "OpenGov", license: "Open Data Commons Open Database License (ODbL) https://opendatacommons.org/licenses/odbl/", description: "Incident level data for all call types in 2021 from the Valcour database. Variables include type of call, origin of call (Officer, Phone, etc), call time and street. It also includes an approximate latitude and longitude for mapping, for all but the most sensitive types of calls.", city: "Burlington", state: "VT", headers: nil, has_911: true, has_fire: false, has_ems: false, analyzed: false}
                     )

b = ActiveStorage::Blob.create!(
                                  {key: "hejk8e99340cc6wtdplrdtmkhb3u", filename: "police-incidents-2022.csv", content_type: "text/csv", metadata: {"identified"=>true, "analyzed"=>true}, service_name: "local", byte_size: 523743, checksum: "P9fzZHbl4EiW+my8Nif0yQ=="}
                                )

ActiveStorage::Attachment.create!(
                                    {name: "files", record_type: "DataSet", record_id: ds.id, blob_id: b.id, row_count: 2826, headers: "incident_number,call_type,call_type_group,call_time,Street,call_origin,mental_health,drug_related,dv_related,alcohol_related,Area,AreaName,Latitude,Longitude,Hour,DayOfWeek,WARD,DISTRICT,priority,Month,year", start_date: nil, end_date: nil}
                                  )

CSV.foreach(Rails.root.join('db', 'import', 'apco_common_incident_types_2.103.2-2019.csv'), headers: true) do |line|
  CommonIncidentType.create! code: line[0], description: line['description'], notes: line['notes']
end
