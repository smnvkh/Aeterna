@raw_text = 'Моя тётя часто рассказывала о летних каникулах в деревне, куда она ездили ещё ребёнком в 1950-е годы. Она вспоминала, как каждое утро просыпалась от криков петуха и запаха свежего хлеба, который пекла бабушка в старой печи. По её словам, дни проходили в простых, но запоминающихся делах: сбор ягод в лесу, купание в речке и прогулки по полям, где она впервые научилась различать дикие цветы. Тётя особенно любила летние вечера, когда все собирались на веранде и рассказывали истории о своих детских шалостях, а взрослые пели песни под гитару. Она говорила, что именно эти моменты дали ей ощущение настоящей свободы и счастья, которое осталось с ней на всю жизнь. Даже спустя десятилетия, вспоминая те деревенские летние дни, она улыбается и говорит, что такого ощущения простого, искреннего радостного детства больше нигде не испытывала.'
@words = @raw_text.downcase.gsub(/[—.—,«»:()]/, '').gsub(/  /, ' ').split(' ')

def seed
  reset_db
  create_posts(10)
  create_comments(2..8)
end

def reset_db
  Rake::Task['db:drop'].invoke
  Rake::Task['db:create'].invoke
  Rake::Task['db:migrate'].invoke
end

def create_sentence
  sentence_words = []

  (10..20).to_a.sample.times do
    sentence_words << @words.sample
  end

  sentence_words.join(' ').capitalize + '.'
end

def create_author
  sentence_words = []

  (1..2).to_a.sample.times do
    sentence_words << @words.sample
  end

  sentence_words.join(' ').capitalize
end

def create_paragraph(sentences_count = 5)
  paragraphs = []
  sentences_count.times do
    paragraphs << create_sentence
  end
  paragraphs.join(' ')
end

def upload_random_image
  uploader = PostCoverUploader.new(Post.new, :cover)
  uploader.cache!(File.open(Dir.glob(File.join(Rails.root, 'public/autoupload/post_covers', '*')).sample))
  uploader
end

def create_posts(quantity)
  quantity.times do
  post = Post.create!(
    title: create_sentence,
    author: create_author,
    body: create_paragraph(5),
    cover: upload_random_image
)
    puts "Post with id #{post.id} just created"
  end
end

def create_comments(quantity)
  Post.all.each do |post|
    quantity.to_a.sample.times do
      comment = post.comments.create!(body: create_sentence)
      puts "Comment with id #{comment.id} for post with id #{comment.post.id} just created"
    end
  end
end

seed
