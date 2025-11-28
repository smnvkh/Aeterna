@raw_text = "Свой первый в жизни рассказ я написал лет пять тому назад..." # твой большой текст
@words = @raw_text.downcase.gsub(/[—.—,«»:()]/, '').gsub(/  /, ' ').split(' ')

def seed
  reset_db
  create_family_members
  create_memories(10)
  create_comments(2..8)
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
def create_family_members
  list = [
    { name: 'Анна', relation: 'мама' },
    { name: 'Иван', relation: 'папа' },
    { name: 'Ольга', relation: 'сестра' },
    { name: 'Пётр', relation: 'брат' },
    { name: 'Мария', relation: 'бабушка' },
    { name: 'Алексей', relation: 'дедушка' }
  ]

  list.each do |attrs|
    FamilyMember.create!(attrs)
  end
end

# ---------- Воспоминания ----------
def create_memories(quantity)
  years = (1950..2020).to_a.sample(5)  # выбираем 5 случайных лет

  years.each do |year|
    rand(1..5).times do  # от 1 до 5 воспоминаний в выбранном году
      date = Date.new(year, rand(1..12), rand(1..28))

      Memory.create!(
        title: create_title,
        body: create_sentence,
        date: date,
        family_member: FamilyMember.all.sample,
        image: upload_random_image
      )

      puts "Memory created for year #{year}"
    end
  end
end



# ---------- Комменты ----------
def create_comments(range)
  Memory.all.each do |memory|
    range.to_a.sample.times do
      comment = memory.comments.create!(body: create_sentence)
      puts "Comment #{comment.id} -> memory #{memory.id}"
    end
  end
end

seed
