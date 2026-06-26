class FamilyMember < ApplicationRecord
  belongs_to :family
  belongs_to :user, optional: true
  has_many :memories, dependent: :destroy
  has_many :collections, dependent: :destroy

  belongs_to :mother, class_name: "FamilyMember", optional: true
  belongs_to :father, class_name: "FamilyMember", optional: true
  belongs_to :spouse, class_name: "FamilyMember", optional: true

  has_many :children_as_mother, class_name: "FamilyMember", foreign_key: "mother_id"
  has_many :children_as_father, class_name: "FamilyMember", foreign_key: "father_id"

  validates :name, presence: true

  before_destroy :detach_from_relations

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
    "#{name}"
  end

  private

  # При удалении узла не оставляем у других FamilyMember висячие
  # mother_id/father_id/spouse_id, указывающие на уже удалённую запись.
  def detach_from_relations
    FamilyMember.where(mother_id: id).update_all(mother_id: nil)
    FamilyMember.where(father_id: id).update_all(father_id: nil)
    FamilyMember.where(spouse_id: id).update_all(spouse_id: nil)
  end
end
