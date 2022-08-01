class User < ApplicationRecord
  has_paper_trail

  belongs_to :role, optional: true

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :confirmable, :trackable

  after_create :set_default_role

  validates :email, presence: true

  def update_role(role_name)
    new_role = Role.find_by(name: role_name)
    return false unless new_role

    update(role: new_role)
  end

  private

  def set_default_role
    return if role

    update(role: Role.find_default_role) # volunteer
  end
end
