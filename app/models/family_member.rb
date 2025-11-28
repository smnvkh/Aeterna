class FamilyMember < ApplicationRecord
  has_many :memories, dependent: :nullify
  belongs_to :user
end
