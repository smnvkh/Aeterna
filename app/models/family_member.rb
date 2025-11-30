class FamilyMember < ApplicationRecord
  belongs_to :user
  has_many :memories, dependent: :destroy

  def to_s
    "#{relation.capitalize} #{name}"
  end

  # Родители
  belongs_to :mother, class_name: "FamilyMember", optional: true
  belongs_to :father, class_name: "FamilyMember", optional: true

  # Супруг/супруга
  belongs_to :spouse, class_name: "FamilyMember", optional: true

  # Дети
  has_many :children_as_mother, class_name: "FamilyMember", foreign_key: :mother_id, dependent: :nullify
  has_many :children_as_father, class_name: "FamilyMember", foreign_key: :father_id, dependent: :nullify

  def children
    children_as_mother + children_as_father
  end

  # Братья/сёстры
  def siblings
    return [] unless mother || father

    FamilyMember.where.not(id: id)
                .where(
                  "mother_id = ? OR father_id = ?",
                  mother_id,
                  father_id
                )
  end

  validates :name, presence: true
  validates :gender, presence: true, inclusion: { in: %w[m f] }

  # validate :parents_not_self

  # def parents_not_self
  #   errors.add(:mother_id, "can't be yourself") if mother_id == id
  #   errors.add(:father_id, "can't be yourself") if father_id == id
  # end
end
