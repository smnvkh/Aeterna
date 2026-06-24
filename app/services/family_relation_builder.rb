# Создаёт нового FamilyMember (или связывает уже существующего, если он
# передан) и проставляет mother_id/father_id/spouse_id исходя из того,
# кем человек приходится уже существующему узлу (source), а не наоборот —
# пользователь думает "кем он мне приходится", а не "что записать в mother_id".
class FamilyRelationBuilder
  include ActiveModel::Model

  RELATION_TYPES = %w[mother father spouse child sibling].freeze

  attr_accessor :source, :relation_type, :name, :gender, :existing_member
  attr_reader :member

  validates :source, presence: true
  validates :relation_type, inclusion: { in: RELATION_TYPES }
  validate :name_or_existing_member_present
  validate :existing_member_belongs_to_same_family
  validate :source_does_not_already_have_relation
  validate :source_has_a_parent_when_adding_sibling
  validate :no_ancestry_cycle

  def call
    return false unless valid?

    FamilyMember.transaction do
      @member = case relation_type
      when "mother"  then add_parent(:mother)
      when "father"  then add_parent(:father)
      when "spouse"  then add_spouse
      when "child"   then add_child
      when "sibling" then add_sibling
      end
    end

    true
  end

  private

  def name_or_existing_member_present
    return if existing_member.present? || name.present?

    errors.add(:name, :blank, message: "укажите имя нового человека или выберите существующего")
  end

  def existing_member_belongs_to_same_family
    return unless existing_member && source

    if existing_member.family_id != source.family_id
      errors.add(:base, :invalid, message: "Выбранный человек принадлежит другой семье")
    elsif existing_member == source
      errors.add(:base, :invalid, message: "Нельзя выбрать того же человека")
    end
  end

  def source_does_not_already_have_relation
    return unless source

    case relation_type
    when "mother"
      errors.add(:base, :duplicate, message: "У #{source.name} уже указана мать") if source.mother.present?
    when "father"
      errors.add(:base, :duplicate, message: "У #{source.name} уже указан отец") if source.father.present?
    when "spouse"
      errors.add(:base, :duplicate, message: "У #{source.name} уже указан супруг(а)") if source.spouse.present?
    end
  end

  def source_has_a_parent_when_adding_sibling
    return unless source
    return unless relation_type == "sibling"

    if source.mother.blank? && source.father.blank?
      errors.add(:base, :missing_parent, message: "Сначала добавьте маму или папу для #{source.name} — иначе у нового брата/сестры не будет общего родителя, и он(а) не отобразится в дереве")
    end
  end

  # Если existing_member выбран как мать/отец/ребёнок/супруг(а), не даём
  # замкнуть петлю в родословной (например, сделать своего же потомка
  # своим предком).
  def no_ancestry_cycle
    return unless existing_member && source
    return unless %w[mother father child].include?(relation_type)

    case relation_type
    when "mother", "father"
      errors.add(:base, :cycle, message: "#{existing_member.name} уже является потомком #{source.name} — так нельзя") if descendant_of?(existing_member, source)
    when "child"
      errors.add(:base, :cycle, message: "#{existing_member.name} уже является предком #{source.name} — так нельзя") if ancestor_of?(existing_member, source)
    end
  end

  def descendant_of?(candidate, person, visited = Set.new)
    return false if visited.include?(person.id)
    visited << person.id

    person.children.any? { |child| child.id == candidate.id || descendant_of?(candidate, child, visited) }
  end

  def ancestor_of?(candidate, person, visited = Set.new)
    return false if visited.include?(person.id)
    visited << person.id

    person.parents.any? { |parent| parent.id == candidate.id || ancestor_of?(candidate, parent, visited) }
  end

  def build_member
    existing_member || FamilyMember.create!(name: name, gender: gender, family: source.family)
  end

  def add_parent(role)
    new_member = build_member
    source.update!(role => new_member)
    new_member
  end

  # Супруг(а) почти всегда — второй родитель уже существующих детей source.
  # Заполняем им только ПУСТОЙ слот (мать/отец) у каждого ребёнка — если он
  # уже занят кем-то другим, не трогаем (приёмные семьи и т.п.).
  def add_spouse
    new_member = build_member
    source.update!(spouse: new_member)
    new_member.update!(spouse: source)

    role = new_member.gender == "m" ? :father : :mother
    source.children.each do |child|
      child.update!(role => new_member) if child.public_send(role).blank?
    end

    new_member
  end

  def add_child
    new_member = build_member
    if source.gender == "f"
      new_member.update!(mother: source, father: source.spouse)
    else
      new_member.update!(father: source, mother: source.spouse)
    end
    new_member
  end

  def add_sibling
    new_member = build_member
    new_member.update!(mother: source.mother, father: source.father)
    new_member
  end
end
