# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

require 'faker'

def generate_fake_apa_citation
  word_count = 5

  author = Faker::Name.name
  date = Time.now.strftime("%Y, %B %d")
  title = Faker::Lorem.sentence(word_count: word_count)
  publisher = Faker::Company.name
  city = Faker::Address.city

  title = title.chomp('.')

  "#{author} (#{date}). #{title}. #{city}: #{publisher}."
end

categories = [
  { name: 'Technology', slug: 'technology', position: 1 },
  { name: 'Science', slug: 'science', position: 2 },
  { name: 'Politics', slug: 'politics', position: 3 },
  { name: 'Sports', slug: 'sports', position: 4 },
  { name: 'Entertainment', slug: 'entertainment', position: 5 }
]

categories.each do |category|
  Category.find_or_create_by!(slug: category[:slug]) do |c|
    c.name = category[:name]
    c.position = category[:position]
  end
end

20.times do
  Article.create!(
    title: Faker::Lorem.sentence(word_count: 5),
    summary: Faker::Lorem.paragraph(sentence_count: 2),
    content: Faker::Lorem.paragraphs(number: 3).join("\n\n"),
    sources: generate_fake_apa_citation,
    category: Category.order('RANDOM()').first,
    image: Faker::LoremFlickr.image,
    sentiment_score: rand(-1.0..1.0).round(2)
  )
end


# AdminUser.create!(email: 'admin@example.com', password: 'password', password_confirmation: 'password') if Rails.env.development?

puts "Seed data created successfully!"
