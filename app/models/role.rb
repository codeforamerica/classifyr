class Role < ApplicationRecord
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
      all: [:all],
    },
    volunteer: {
      dashboard: [:index, :show],
      data_sets: [:index, :show],
    },
    data_importer: {
      dashboard: [:index, :show],
      data_sets: [:index, :show, :create, :update],
    },
    data_classifier: {
      dashboard: [:index, :show],
      classifications: [:index, :create],
      categories: [:request],
    },
    data_consumer: {
      dashboard: [:index, :show],
      data_sets: [:export],
    },
    data_reviewer: {
      dashboard: [:index, :show],
      data_categorization: [:review],
    },
  }.freeze

  def self.insert_roles
    Role::ROLE_PERMISSIONS.each do |role_name, _permissions|
      next if Role.find_by(name: role_name)

      Role.create!(name: role_name)
    end
  end

  def self.find_default_role
    find_by(name: DEFAULT_ROLE_NAME)
  end

  def humanized_name
    name.humanize.titleize
  end

  def authorized?(action, entity)
    permissions = ROLE_PERMISSIONS[name.to_sym]

    return false unless permissions
    return true if permissions[:all]
    return false unless permissions[entity]
    return true if permissions[entity]&.include?(:all)

    permissions[entity].include?(action)
  end
end
