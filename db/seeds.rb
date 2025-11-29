@raw_text = "Свой первый в жизни рассказ я написал лет пять тому назад..." # твой большой текст
@words = @raw_text.downcase.gsub(/[—.—,«»:()]/, '').gsub(/  /, ' ').split(' ')

def seed
  reset_db
  create_users(5)
  create_family_members
  create_memories(35)
  create_comments(1..3)
end

def reset_db
  Rake::Task['db:drop'].invoke
  Rake::Task['db:create'].invoke
  Rake::Task['db:migrate'].invoke
end

# ---------- Генерация заголовка ----------
def create_title
  title_words = []
  (2..10).to_a.sample.times { title_words << @words.sample }
  title_words.join(' ').capitalize + '.'
end

# ---------- Генерация текста ----------
def create_sentence
  sentence_words = []
  (10..20).to_a.sample.times { sentence_words << @words.sample }
  sentence_words.join(' ').capitalize + '.'
end

# ---------- Фото ----------
def upload_random_image
  uploader = MemoryImageUploader.new(Memory.new, :image)
  uploader.cache!(File.open(Dir.glob(File.join(Rails.root, 'public/autoupload/memory_images', '*')).sample))
  uploader
end

# ---------- Семья ----------
# def create_family_members
#   list = [
#     { name: 'Анна', relation: 'мама' },
#     { name: 'Иван', relation: 'папа' },
#     { name: 'Ольга', relation: 'сестра' },
#     { name: 'Пётр', relation: 'брат' },
#     { name: 'Мария', relation: 'бабушка' },
#     { name: 'Алексей', relation: 'дедушка' }
#   ]

#   list.each do |attrs|
#     FamilyMember.create!(attrs)
#   end
# end

def create_family_members
  list = [
    { name: 'Анна', relation: 'мама' },
    { name: 'Иван', relation: 'папа' },
    { name: 'Ольга', relation: 'сестра' },
    { name: 'Пётр', relation: 'брат' },
    { name: 'Мария', relation: 'бабушка' },
    { name: 'Алексей', relation: 'дедушка' }
  ]

  User.find_each do |user|
    list.each do |attrs|
      FamilyMember.create!(attrs.merge(user: user))
    end
    puts "Family members created for user #{user.id}"
  end
end


def create_users(quantity)
  i = 0

  quantity.times do
    user_data = {
      email: "user_#{i}@email.com",
      password: "testtest"
    }

    user = User.create!(user_data)
    puts "User created with id #{user.id}"

    i += 1
  end
end


# def create_memories(quantity)
#   years = (1950..2020).to_a.sample(5)  # выбираем 5 случайных лет

#   years.each do |year|
#     rand(1..5).times do  # от 1 до 5 воспоминаний в выбранном году
#       date = Date.new(year, rand(1..12), rand(1..28))

#       Memory.create!(
#         title: create_title,
#         body: create_sentence,
#         date: date,
#         family_member: FamilyMember.all.sample,
#         image: upload_random_image
#       )

#       puts "Memory created for year #{year}"
#     end
#   end
# end

def create_memories(quantity)
  years = (1950..2020).to_a.sample(5)

  years.each do |year|
    rand(1..5).times do
      user = User.all.sample
      family_member = user.family_members.sample   # берём родственника ЭТОГО пользователя

      date = Date.new(year, rand(1..12), rand(1..28))

      user.memories.create!(
        title: create_title,
        body: create_sentence,
        date: date,
        family_member: family_member,
        image: upload_random_image
      )

      puts "Memory created for year #{year} (user #{user.id})"
    end
  end
end




# ---------- Комменты ----------
# def create_comments(range)
#   Memory.all.each do |memory|
#     range.to_a.sample.times do
#       comment = memory.comments.create!(body: create_sentence)
#       puts "Comment #{comment.id} -> memory #{memory.id}"
#     end
#   end
# end

def create_comments(range)
  Memory.find_each do |memory|
    range.to_a.sample.times do
      user = memory.user
      comment = memory.comments.create!(
        body: create_sentence,
        user: user
      )
      puts "Comment #{comment.id} -> memory #{memory.id}"
    end
  end
end


seed
