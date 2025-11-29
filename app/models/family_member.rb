class FamilyMember < ApplicationRecord
  has_many :memories, dependent: :destroy

  def to_s
    "#{relation.capitalize} #{name}"
  end

  belongs_to :user
end
