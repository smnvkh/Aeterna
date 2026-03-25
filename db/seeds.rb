@raw_text = "Свой первый в жизни рассказ я написал лет пять тому назад..."
@words = @raw_text.downcase.gsub(/[—.—,«»:()]/, '').gsub(/  /, ' ').split(' ')

TAG_POOL = %w[Семья Детство Школа Праздник Каникулы Друзья Радость Мама Любовь Игра]
COLLECTION_POOL = [
  "Ездили в поле собирать полевые цветы",
  "Первая совместная поездка на море",
  "На даче с семьей",
  "Рождение дорогой внучки"
]

def seed
  reset_db
  clean_uploads_folder
  create_admin_user
  create_family
  create_users(5)
  create_family_members
  create_memories
  create_collections
  create_comments(2..8)
end

# ----------------- Базовые методы -----------------
def reset_db
  Rake::Task['db:drop'].invoke
  Rake::Task['db:create'].invoke
  Rake::Task['db:migrate'].invoke
end

def clean_uploads_folder
  FileUtils.rm_rf('public/uploads')
  puts "Uploads folder just cleaned"
end

def create_title
  Array.new((2..10).to_a.sample) { @words.sample }.join(' ').capitalize + '.'
end

def create_sentence
  Array.new((10..20).to_a.sample) { @words.sample }.join(' ').capitalize + '.'
end

def upload_random_image
  uploader = MemoryImageUploader.new(Memory.new, :image)
  uploader.cache!(
    File.open(
      Dir.glob(File.join(Rails.root, 'public/autoupload/memory_images', '*')).sample
    )
  )
  uploader
end

# ----------------- Пользователи и семьи -----------------
def create_admin_user
  family = Family.create!(name: "Семья админа")
  user = User.create!(email: "admin@email.com", password: "123123", admin: true, family: family)
  puts "Admin user created with id #{user.id} and family #{family.name}"
end

def create_family
  @family = Family.create!(name: "Семья Ивановых")
  puts "Family created: #{@family.name}"
end

def create_users(quantity)
  @users = []
  quantity.times do |i|
    @users << User.create!(email: "user_#{i}@email.com", password: "123123", family: @family)
  end
  puts "#{quantity} users created"
end

def create_family_members
  grandmother = FamilyMember.create!(name: "Мария", relation: "бабушка", family: @family)
  grandfather = FamilyMember.create!(name: "Алексей", relation: "дедушка", family: @family)
  grandmother.update!(spouse: grandfather)
  grandfather.update!(spouse: grandmother)

  mother = FamilyMember.create!(name: "Анна", relation: "мама", family: @family, mother: grandmother, father: grandfather)
  father = FamilyMember.create!(name: "Иван", relation: "папа", family: @family)
  mother.update!(spouse: father)
  father.update!(spouse: mother)

  sister = FamilyMember.create!(name: "Ольга", relation: "сестра", family: @family)
  brother = FamilyMember.create!(name: "Пётр", relation: "брат", family: @family)

  @family_members = [ grandmother, grandfather, mother, father, sister, brother ]

  # связываем users и family_members
  @family_members.zip(@users).each { |member, user| member.update!(user: user) if user }
  puts "Family members created: #{@family_members.count}"
end

# ----------------- Воспоминания -----------------
def create_memories
  @family.family_members.find_each do |member|
    rand(1..3).times do
      type = [ :text_only, :image_only, :both ].sample
      memory = Memory.new(
        title: create_title,
        date: Date.new(rand(1950..2020), rand(1..12), rand(1..28)),
        family: @family,
        family_member: member
      )

      # Генерация контента
      memory.body = create_sentence if [ :text_only, :both ].include?(type)
      memory.image = upload_random_image if [ :image_only, :both ].include?(type)
      memory.save!  # сохраняем уже валидную память

      # Теги
      memory.tag_list.add(TAG_POOL.sample(rand(1..3)))
      memory.save!

      puts "Memory #{memory.id} created for #{member.name} (#{type}) with tags: #{memory.tag_list.join(', ')}"
    end
  end
end

# ----------------- Коллекции (категории) -----------------
def create_collections
  memories = Memory.all
  COLLECTION_POOL.each do |collection|
    selected_memories = memories.sample(rand(2..4))
    selected_memories.each do |memory|
      # Добавляем категорию без валидации (чтобы не падало на body_or_image_present)
      memory.category_list.add(collection)
      memory.save(validate: false)
      puts "Collection '#{collection}' added to Memory #{memory.id}"
    end
  end
end

# ----------------- Комментарии -----------------
def create_comments(range)
  Memory.find_each do |memory|
    range.to_a.sample.times do
      author = memory.family.users.sample
      comment = memory.comments.create!(body: create_sentence, user: author)
      puts "Comment #{comment.id} -> Memory #{memory.id} (user #{author.id})"
    end
  end
end

# ----------------- Запуск -----------------
seed
