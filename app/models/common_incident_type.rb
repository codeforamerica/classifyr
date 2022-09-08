require "csv"

class CommonIncidentType < ApplicationRecord
  include PgSearch::Model
  pg_search_scope :search,
                  against: [
                    :code, :description, :notes,
                    :humanized_code, :humanized_description,
                    :humanized_notes
                  ],
                  using: {
                    tsearch: {
                      dictionary: "english",
                      prefix: true,
                    },
                    trigram: {
                      word_similarity: true,
                    },
                  }

  has_paper_trail

  EXPORT_COLUMNS = %w[id standard version code description notes humanized_code humanized_description].freeze

  has_many :classifications, dependent: :destroy

  scope :apco, -> { where(standard: "APCO") }

  def formatted_code
    humanized_code || code
  end

  def formatted_description
    humanized_description || description
  end

  def formatted_notes
    humanized_notes || notes
  end

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
