class Family < ApplicationRecord
  has_many :users
  has_many :memories, dependent: :destroy
  has_many :family_members
end
