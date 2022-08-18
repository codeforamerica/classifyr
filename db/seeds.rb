require "csv"

# Insert an initial data set

ds = DataSet.create!(
  {
    title: "Burlington, VT Police Incidents",
    data_link: "https://data.burlingtonvt.gov/explore/?refine.theme=Public+Safety&disjunctive.theme&disjunctive.publisher&disjunctive.keyword&sort=modified",
    documentation_link: "https://data.burlingtonvt.gov/explore/dataset/police-incidents-2021/information/",
    api_links: "https://data.burlingtonvt.gov/explore/dataset/police-incidents-2021/api/",
    source: "Burlington Police Department; contact  jlarson@burlingtonvt.gov",
    exclusions: "\"the most sensitive types of calls,\" not specified",
    format: "OpenGov",
    license: "Open Data Commons Open Database License (ODbL) https://opendatacommons.org/licenses/odbl/",
    description: "Incident level data for all call types in 2021 from the Valcour database. Variables include type of call, origin of call (Officer, Phone, etc), call time and street. It also includes an approximate latitude and longitude for mapping, for all but the most sensitive types of calls.",
    city: "Burlington",
    state: "VT",
    headers: nil,
    has_911: true,
    has_fire: false,
    has_ems: false,
    analyzed: false,
    files: [
      # Changed to using this to support having the attached file as required on
      # data set creation.
      Rack::Test::UploadedFile.new("db/files/police-incidents-2022.csv", "text/csv"),
    ],
  },
)

CSV.foreach(Rails.root.join("db", "import", "apco_common_incident_types_2.103.2-2019.csv"), headers: true) do |line|
  next if CommonIncidentType.find_by(code: line["code"])

  CommonIncidentType.create! code: line["code"], description: line["description"], notes: line["notes"]
end

Role.insert_roles
