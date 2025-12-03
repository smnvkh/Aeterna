class FamilyMember < ApplicationRecord
  belongs_to :family
  has_many :memories, dependent: :destroy

  belongs_to :mother, class_name: "FamilyMember", optional: true
  belongs_to :father, class_name: "FamilyMember", optional: true
  belongs_to :spouse, class_name: "FamilyMember", optional: true

  has_many :children_as_mother, class_name: "FamilyMember", foreign_key: "mother_id"
  has_many :children_as_father, class_name: "FamilyMember", foreign_key: "father_id"

  validates :name, presence: true

  # --- Родственные методы ---
  def parents
    [ mother, father ].compact
  end

  def children
    children_as_mother + children_as_father
  end

  def siblings
    return [] if parents.empty?
    (mother&.children_as_mother.to_a + father&.children_as_father.to_a - [ self ]).uniq
  end

  def grandchildren
    children.flat_map(&:children)
  end

  def grandparents
    parents.flat_map(&:parents)
  end

  def uncles_and_aunts
    parents.flat_map(&:siblings)
  end

  def cousins
    uncles_and_aunts.flat_map(&:children)
  end

  def to_s
    "#{relation.to_s.capitalize} #{name}"
  end
end
