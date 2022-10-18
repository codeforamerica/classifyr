# frozen_string_literal: true

namespace :export do
  desc 'Export APCO Common Incident Types'
  task apco: :environment do
    puts CommonIncidentType.to_csv
  end
end
