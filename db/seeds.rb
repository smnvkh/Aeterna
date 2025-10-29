# ---- Исходные данные ----
@texts = 'Каждая деталь хранит в себе память. Иногда это запах кофе, иногда свет утреннего окна.
Мы вспоминаем не даты, а чувства. Главное — уметь хранить это бережно.
'.downcase.gsub(/[—.—,«»:()]/, '').split(' ')

MEMORY_TOPICS = [
  'Детство на даче',
  'Первый снег',
  'Утро перед поездкой',
  'Письмо из прошлого',
  'Ночной город',
  'Голос в трубке',
  'Старое фото в альбоме',
  'Запах сирени',
  'Звук моря',
  'Праздничный стол'
]

COMMENT_TEMPLATES = [
  'Очень атмосферно!',
  'Это будто про меня.',
  'Как живо описано.',
  'Сразу вспоминается детство.',
  'Пронзительно и красиво.'
]

# ---- Методы ----

def seed
  reset_db
  users = create_users(5)
  memories = create_memories(users, 15)
  create_comments(users, memories, 2..4)
  puts "Seeding complete!"
end

def reset_db
  Comment.destroy_all
  Memory.destroy_all
  User.destroy_all
  puts "🧹 Database cleaned"
end

def random_sentence
  Array.new(rand(8..14)) { @texts.sample }.join(' ').capitalize + '.'
end

def create_users(quantity)
  puts "Создаём пользователей..."
  quantity.times.map do |i|
    User.create!(
      email: "user#{i+1}@example.com",
      password: "123456"
    )
  end
end

def create_memories(users, quantity)
  puts "Создаём воспоминания..."
  quantity.times.map do
    Memory.create!(
      user: users.sample,
      title: MEMORY_TOPICS.sample,
      body: random_sentence
    )
  end
end

def create_comments(users, memories, quantity_range)
  puts "Добавляем комментарии..."
  memories.each do |memory|
    rand(quantity_range).times do
      available_users = users.reject { |u| u.id == memory.user_id }
      Comment.create!(
        memory: memory,
        user: available_users.sample,
        body: COMMENT_TEMPLATES.sample
      )
    end
  end
end

# ---- Запуск ----
seed
