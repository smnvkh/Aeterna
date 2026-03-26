@raw_text = "Свой первый в жизни рассказ я написал лет пять тому назад..."
@words = @raw_text.downcase.gsub(/[—.—,«»:()]/, '').gsub(/  /, ' ').split(' ')

def seed
  reset_db
  clean_uploads_folder
  create_admin_user
  create_family
  create_users(5)
  create_family_members
  create_memories
  create_comments(2..8)
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

# ---------- Фото ----------
def upload_random_image
  uploader = MemoryImageUploader.new(Memory.new, :image)
  uploader.cache!(
    File.open(
      Dir.glob(File.join(Rails.root, 'public/autoupload/memory_images', '*')).sample
    )
  )
  uploader
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

def create_users(quantity)
  @users = []
  quantity.times do |i|
    @users << User.create!(email: "user_#{i}@email.com", password: "123123", family: @family)
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
    member.update!(user: user)
  end
  puts "Family members created: #{@family_members.count}"
end

# ------------------ Воспоминания ------------------
TAG_POOL = %w[семья детство школа праздник лето воспоминание друзья радость смех любовь игра]

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
      case type
      when :text_only
        memory.body = create_sentence
      when :image_only
        memory.image = upload_random_image
      when :both
        memory.body = create_sentence
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

# ------------------ Комментарии ------------------
def create_comments(range)
  Memory.find_each do |memory|
    range.to_a.sample.times do
      author = memory.family.users.sample
      comment = memory.comments.create!(body: create_sentence, user: author)
      puts "Comment #{comment.id} -> Memory #{memory.id} (user #{author.id})"
    end
  end
end

seed
