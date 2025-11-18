class FamilyMember < ApplicationRecord
  has_many :memories, dependent: :nullify
end
