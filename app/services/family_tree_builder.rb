# Строит данные для страницы "Семейное древо" относительно конкретного
# человека (me): какие узлы показывать, в какой "слот" (визуальная группа)
# их класть и какой подписью отметить ("мама", "папа", "муж" и т.д.).
# Сама раскладка по координатам — забота view/CSS, тут только данные.
class FamilyTreeBuilder
  Node = Struct.new(:member, :slot, :label, keyword_init: true)

  attr_reader :me

  def initialize(me)
    @me = me
  end

  def nodes
    @nodes ||= build_nodes
  end

  # Пары [id, id] для соединительных линий между узлами.
  def edges
    @edges ||= build_edges
  end

  private

  def mothers_parents
    @mothers_parents ||= me.mother&.parents || []
  end

  def fathers_parents
    @fathers_parents ||= me.father&.parents || []
  end

  def spouses_parents
    @spouses_parents ||= me.spouse&.parents || []
  end

  def fathers_siblings
    @fathers_siblings ||= me.father&.siblings || []
  end

  def mothers_siblings
    @mothers_siblings ||= me.mother&.siblings || []
  end

  def fathers_great_grandparents
    @fathers_great_grandparents ||= fathers_parents.flat_map(&:parents).uniq
  end

  def mothers_great_grandparents
    @mothers_great_grandparents ||= mothers_parents.flat_map(&:parents).uniq
  end

  def build_nodes
    list = [ Node.new(member: me, slot: :me, label: "это вы") ]

    add_single(list, me.mother, :mother, "мама")
    add_single(list, me.father, :father, "папа")
    add_single(list, me.spouse, :spouse, spouse_label)

    add_many(list, me.children, :child) { |child| child_label(child) }
    add_many(list, me.siblings, :sibling) { |sibling| sibling_label(sibling) }
    add_many(list, fathers_siblings, :father_sibling) { |a| aunt_uncle_label(a) }
    add_many(list, mothers_siblings, :mother_sibling) { |a| aunt_uncle_label(a) }
    add_many(list, me.cousins, :cousin) { "двоюродн#{me.gender == 'm' ? 'ый брат' : 'ая сестра'}" }

    add_many(list, mothers_parents, :mothers_parent) { |p| grandparent_label(p) }
    add_many(list, fathers_parents, :fathers_parent) { |p| grandparent_label(p) }
    add_many(list, spouses_parents, :spouses_parent) { |p| grandparent_label(p, in_law: true) }
    add_many(list, fathers_great_grandparents, :father_great_grandparent) { |p| great_grandparent_label(p) }
    add_many(list, mothers_great_grandparents, :mother_great_grandparent) { |p| great_grandparent_label(p) }

    list
  end

  def build_edges
    list = []
    list << [ me.id, me.mother_id ] if me.mother_id
    list << [ me.id, me.father_id ] if me.father_id
    list << [ me.id, me.spouse_id ] if me.spouse_id

    me.children.each { |c| list << [ me.id, c.id ] }
    me.siblings.each { |s| list << [ me.id, s.id ] }
    me.cousins.each { |c| list << [ me.id, c.id ] }

    fathers_siblings.each { |a| list << [ me.father_id, a.id ] }
    mothers_siblings.each { |a| list << [ me.mother_id, a.id ] }

    mothers_parents.each { |p| list << [ me.mother_id, p.id ] }
    fathers_parents.each { |p| list << [ me.father_id, p.id ] }
    spouses_parents.each { |p| list << [ me.spouse_id, p.id ] }

    fathers_great_grandparents.each do |gg|
      owner = fathers_parents.find { |g| g.parents.include?(gg) }
      list << [ owner.id, gg.id ] if owner
    end

    mothers_great_grandparents.each do |gg|
      owner = mothers_parents.find { |g| g.parents.include?(gg) }
      list << [ owner.id, gg.id ] if owner
    end

    list
  end

  def add_single(list, member, slot, label)
    return unless member

    list << Node.new(member: member, slot: slot, label: label)
  end

  def add_many(list, members, slot)
    members.each do |member|
      list << Node.new(member: member, slot: slot, label: block_given? ? yield(member) : nil)
    end
  end

  def spouse_label
    return nil unless me.spouse

    me.spouse.gender == "m" ? "муж" : "жена"
  end

  def child_label(child)
    child.gender == "m" ? "сын" : "дочь"
  end

  def sibling_label(sibling)
    sibling.gender == "m" ? "брат" : "сестра"
  end

  def aunt_uncle_label(member)
    member.gender == "m" ? "дядя" : "тётя"
  end

  def grandparent_label(member, in_law: false)
    base = member.gender == "m" ? "дедушка" : "бабушка"
    in_law ? "#{base} супруга" : base
  end

  def great_grandparent_label(member)
    member.gender == "m" ? "прадедушка" : "прабабушка"
  end
end
