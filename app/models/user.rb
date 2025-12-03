class User < ApplicationRecord
  devise :database_authenticatable, # :registerable,
         :recoverable, :rememberable, :validatable

  belongs_to :family

  has_many :memories
  has_many :comments
end
