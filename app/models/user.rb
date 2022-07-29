class User < ApplicationRecord
  has_paper_trail

  belongs_to :role, optional: true

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :confirmable, :trackable
end
