require "csv"

class CommonIncidentType < ApplicationRecord
  has_paper_trail

  EXPORT_COLUMNS = %w[id standard version code description notes humanized_code humanized_description].freeze

  has_many :classifications, dependent: :destroy

  def self.to_csv
    cits = all
    CSV.generate do |csv|
      csv << EXPORT_COLUMNS
      cits.each do |cit|
        csv << cit.attributes.values_at(*EXPORT_COLUMNS)
      end
    end
  end
end
