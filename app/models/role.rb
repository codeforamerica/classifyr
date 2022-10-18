# frozen_string_literal: true

# Represents a user role.
class Role < ApplicationRecord
  include AppConfig

  has_paper_trail
  has_many :users, dependent: :nullify

  DEFAULT_ROLE_NAME = :volunteer

  # entities:
  # - all
  # - dashboard
  # - data_sets
  # - classifications
  # - users
  # - roles
  #
  # actions:
  # - all
  # - index
  # - show
  # - create
  # - update
  # - destroy
  # - classify
  # - export
  # - review
  #
  ROLE_PERMISSIONS = {
    data_admin: {
      all: [:all]
    },
    volunteer: {
      classifications: [:index],
      dashboard: %i[index show],
      data_sets: %i[index show]
    },
    data_importer: {
      classifications: [:index],
      dashboard: %i[index show],
      data_sets: %i[index show create update]
    },
    data_classifier: {
      categories: [:request],
      classifications: %i[index create],
      common_incident_types: [:index],
      dashboard: %i[index show],
      data_sets: %i[index show create update]
    },
    data_consumer: {
      classifications: [:index],
      dashboard: %i[index show],
      data_sets: [:export]
    },
    data_reviewer: {
      classifications: [:index],
      dashboard: %i[index show],
      data_categorization: [:review]
    }
  }.freeze

  def self.insert_roles
    Role::ROLE_PERMISSIONS.each do |role_name, _permissions|
      next if Role.find_by(name: role_name)

      Role.create!(name: role_name)
    end
  end

  def self.find_default_role
    find_by(name: config[:default] || DEFAULT_ROLE_NAME)
  end

  def to_s
    humanized_name
  end

  def humanized_name
    name.humanize.titleize
  end
end
