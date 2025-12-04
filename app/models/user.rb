class User < ApplicationRecord
  devise :database_authenticatable, # :registerable,
         :recoverable, :rememberable, :validatable

  belongs_to :family

  has_many :comments, dependent: :destroy

  # Косвенный доступ:
  has_many :memories, through: :family
end
