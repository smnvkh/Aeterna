@raw_text = "Каждое лето мы ездили на дачу к деду. Он просыпался раньше всех и варил кашу на молоке. Я притворялся, что сплю, просто чтобы послушать, как он тихонько насвистывает. Мама никогда не называла меня по имени, когда злилась — только «молодой человек». Я слышал это слово и сразу знал: всё серьёзно. У нас была традиция: в Новый год папа прятал мандарин. Кто найдёт — загадывает желание. Я не знал до двадцати лет, что он прятал его специально для меня каждый раз. Бабушка хранила конфеты в жестяной коробке из-под чая. Мы все знали, где она, но никто никогда не брал без спроса. Это был негласный закон. Первый раз, когда я помог папе починить кран, он сказал: «Хорошая работа» Больше он так никогда не говорил. Но я запомнил."
@words = @raw_text.downcase.gsub(/[—.—,«»:()]/, '').gsub(/  /, ' ').split(' ')

def seed
  reset_db
  clean_uploads_folder
  create_admin_user
  create_family
  create_users(6)
  create_family_members
  create_memories
  create_collections
  # create_comments(2..8)
end

# ------------------ Базовые методы ------------------
def reset_db
  Rake::Task['db:drop'].invoke
  Rake::Task['db:create'].invoke
  Rake::Task['db:migrate'].invoke
end

def clean_uploads_folder
  FileUtils.rm_rf('public/uploads')
  puts "Uploads folder just cleaned"
end

# ---------- Генерация текста ----------
def create_title
  Array.new((2..10).to_a.sample) { @words.sample }.join(' ').capitalize + '.'
end

def create_sentence
  Array.new((10..20).to_a.sample) { @words.sample }.join(' ').capitalize + '.'
end

def create_paragraph
  Array.new((3..6).to_a.sample) { create_sentence }.join(' ')
end

def create_body
  Array.new((1..3).to_a.sample) { create_paragraph }.join("\n\n")
end

# ---------- Аватарки ----------
PROFILE_IMAGES = Dir.glob(File.join(Rails.root, 'public/autoupload/profile_images', '*')).sort

def attach_profile_avatar(profile, index)
  image_path = PROFILE_IMAGES[index % PROFILE_IMAGES.length]
  profile.avatar.attach(
    io: File.open(image_path),
    filename: File.basename(image_path),
    content_type: "image/jpeg"
  )
end

# ---------- Фото ----------
def upload_random_image
  File.open(Dir.glob(File.join(Rails.root, 'public/autoupload/memory_images', '*')).sample)
end

# ------------------ Пользователи ------------------
def create_admin_user
  family = Family.create!(name: "Семья админа")
  user_data = { email: "admin@email.com", password: "123123", admin: true, family: family }
  user = User.create!(user_data)
  puts "Admin user created with id #{user.id} and family #{family.name}"
end

# ------------------ Семья ------------------
def create_family
  @family = Family.create!(name: "Семья Ивановых")
  puts "Family created: #{@family.name}"
end

NAMES = [
  [ "Мария", "Иванова" ], [ "Алексей", "Иванов" ], [ "Анна", "Смирнова" ],
  [ "Иван", "Петров" ], [ "Ольга", "Сидорова" ], [ "Пётр", "Козлов" ]
]

BIRTHDAYS = [
  Date.new(1948, 3, 12), Date.new(1945, 7, 24), Date.new(1972, 11, 5),
  Date.new(1970, 4, 18), Date.new(1998, 9, 3), Date.new(2001, 1, 30)
]

def create_users(quantity)
  @users = []
  quantity.times do |i|
    user = User.create!(email: "user_#{i}@email.com", password: "123123", family: @family)
    name = NAMES[i % NAMES.length].join(' ')
    birthday = BIRTHDAYS[i % BIRTHDAYS.length]
    profile = Profile.create!(user: user, name: name, birthday: birthday)
    attach_profile_avatar(profile, i)
    puts "User #{user.email} created with profile '#{name}' and avatar"
    @users << user
  end
  puts "#{quantity} users created"
end

# ------------------ Родственники ------------------
def create_family_members
  grandmother = FamilyMember.create!(name: "Мария", relation: "бабушка", family: @family)
  grandfather = FamilyMember.create!(name: "Алексей", relation: "дедушка", family: @family)
  grandmother.update!(spouse: grandfather)
  grandfather.update!(spouse: grandmother)

  mother = FamilyMember.create!(name: "Анна", relation: "мама", family: @family, mother: grandmother, father: grandfather)
  father = FamilyMember.create!(name: "Иван", relation: "папа", family: @family)
  father.update!(spouse: mother)
  mother.update!(spouse: father)

  sister = FamilyMember.create!(name: "Ольга", relation: "сестра", family: @family)
  brother = FamilyMember.create!(name: "Пётр", relation: "брат", family: @family)

  @family_members = [ grandmother, grandfather, mother, father, sister, brother ]

  # связываем users и family_members
  @family_members.zip(@users).each do |member, user|
    break unless user
    # User#setup_new_user уже создал заглушку FamilyMember при User.create! —
    # удаляем её, иначе пользователь окажется на слайдере дважды
    stub = user.family_member
    stub.destroy! if stub && stub.id != member.id
    member.update!(user: user)
  end
  puts "Family members created: #{@family_members.count}"
end

# ------------------ Воспоминания ------------------
TAG_POOL = %w[семья детство школа праздник лето воспоминание друзья радость смех любовь игра]

def create_memories
  @family.family_members.find_each do |member|
    rand(5..15).times do
      type = [ :text_only, :image_only, :both ].sample
      memory = Memory.new(
        title: create_title,
        date: Date.new(rand(1950..2020), rand(1..12), rand(1..28)),
        family: @family,
        family_member: member
      )

      # Генерация контента
      case type
      when :text_only
        memory.body = create_body
      when :image_only
        memory.image = upload_random_image
      when :both
        memory.body = create_body
        memory.image = upload_random_image
      end

      memory.save! # сохраняем память

      # Генерируем 1–3 случайных тега
      memory.tag_list.add(TAG_POOL.sample(rand(1..3)))
      memory.save!

      puts "Memory #{memory.id} created for #{member.name} (#{type}) with tags: #{memory.tag_list.join(', ')}"
    end
  end
  puts "Created shared memories for family #{@family.name}"
end

# ------------------ Подборки ------------------
COLLECTION_TITLES = [
  "Лучшие моменты лета", "Семейные праздники", "Детство", "Школьные годы",
  "Наши путешествия", "Истории дедушки", "Смешные истории", "Воспоминания о даче"
]

def create_collections
  @family.family_members.find_each do |member|
    member_memories = member.memories.to_a
    next if member_memories.empty?

    rand(1..3).times do
      memory_pool = member_memories.sample(rand(1..[ member_memories.count, 6 ].min))
      next if memory_pool.empty?

      collection = Collection.new(
        title: COLLECTION_TITLES.sample,
        date: memory_pool.map(&:date).compact.min || Date.new(rand(1950..2020), rand(1..12), rand(1..28)),
        family: @family,
        family_member: member
      )
      collection.memory_ids = memory_pool.map(&:id)
      collection.save!

      collection.category_list.add(TAG_POOL.sample(rand(1..2)))
      collection.save!

      puts "Collection '#{collection.title}' created for #{member.name} with #{memory_pool.size} memories"
    end
  end
  puts "Created collections for family #{@family.name}"
end

# ------------------ Комментарии ------------------
# def create_comments(range)
#   Memory.find_each do |memory|
#     range.to_a.sample.times do
#       author = memory.family.users.sample
#       comment = memory.comments.create!(body: create_sentence, user: author)
#       puts "Comment #{comment.id} -> Memory #{memory.id} (user #{author.id})"
#     end
#   end
# end

seed
