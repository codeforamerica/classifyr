class Role < ApplicationRecord
  has_paper_trail
  has_many :users, dependent: :nullify

  # Set up roles
  # entities:
  # all, dashboard, data_sets, classifications, users, roles
  # actions:
  # all, view (index + show), index, show, create, update, destroy, classify, export, review
  ROLES_CONFIGURATION = {
    "Volunteer" => {
      dashboard: [:view],
      data_sets: [:view],
    },
    "Data Admin" => {
      all: [:all],
    },
    "Data Importer" => {
      dashboard: [:view],
      data_sets: [:view, :create, :update],
    },
    "Data Classifier" => {
      dashboard: [:view],

    },
    "Data Consumer" => {
      dashboard: [:view],
      data_sets: [:export],
    },
    "Data Reviewer" => {
      data_categorization: [:review],
    },
  }.freeze
end
