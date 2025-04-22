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
  { name: 'Politics', slug: 'politics' },
  { name: 'World', slug: 'world' },
  { name: 'Technology', slug: 'technology' },
  { name: 'Finance', slug: 'finance' },
  { name: 'Sports', slug: 'sports' }
]

categories.each_with_index do |category, index|
  Category.find_or_create_by!(slug: category[:slug]) do |c|
    c.name = category[:name]
    c.position = index
  end
end

feeds = [
  {
    url: "https://rss.politico.com/politics-news.xml",
    name: "Politico Politics",
    category_id: Category.find_by(name: 'Politics').id
  },
  {
    url: "https://feeds.npr.org/1014/rss.xml",
    content_selector: '.story',
    name: "NPR Politics",
    category_id: Category.find_by(name: 'Politics').id
  },
  {
    url: "https://feeds.bbci.co.uk/news/world/rss.xml",
    content_selector: "article",
    name: "BBC World",
    category_id: Category.find_by(name: 'World').id
  },
  {
    url: "https://www.theverge.com/rss/index.xml",
    content_selector: 'article',
    name: "The Verge Technology",
    category_id: Category.find_by(name: 'Technology').id
  },
  {
    url: "https://www.cnbc.com/id/10000664/device/rss/rss.html",
    content_selector: '.group',
    name: "CNBC Finance",
    category_id: Category.find_by(name: 'Finance').id
  },
  {
    url: "https://www.espn.com/espn/rss/news",
    content_selector: '.container',
    name: "ESPN Sports",
    category_id: Category.find_by(name: 'Sports').id
  }
]

feeds.each do |feed|
  Feed.create(feed)
end

# AdminUser.create!(email: 'admin@example.com', password: 'password', password_confirmation: 'password') if Rails.env.development?

puts "Seed data created successfully!"
