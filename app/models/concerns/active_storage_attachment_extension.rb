# frozen_string_literal: true

# Helper methods for models that work with files.
module ActiveStorageAttachmentExtension
  extend ActiveSupport::Concern

  included do
    # TD -
    # Commenting this out since it's not part of the MVP
    # And it's preventing the deletion of data sets.
    # has_many :virus_scan_results, dependent: :destroy
  end

  def with_file(&)
    blob.open(&)
  end

  def analyze!; end

  def set_metadata!
    blob.open do |f|
      self.row_count = `wc -l #{f.path}`.split.first.to_i - 1
      self.headers = `head -1 #{f.path}`.chomp
    end

    save!
  end
end
