class User < ApplicationRecord
  has_paper_trail

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :confirmable, :trackable
end
