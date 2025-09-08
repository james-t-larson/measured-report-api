# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

# TODO: Certain categories do not need sentimenlity checked
# I imagine that this is the case for other verfications
# -- Create a validations required table to skip/require validations
categories = [
  { name: 'Civic Affairs', slug: 'civics' },
  { name: 'Traffic', slug: 'traffic' }
]

categories.each_with_index do |category, index|
  Category.find_or_create_by!(slug: category[:slug]) do |c|
    c.name = category[:name]
    c.position = index + 1
  end
end

feeds = [
  {
    url: "https://www.coquitlam.ca/RSSFeed.aspx?ModID=1&CID=Road-Work-and-Construction-5",
    name: "Coquitlam Construction",
    category_id: Category.find_by(slug: 'traffic').id
  }
]

feeds.each do |feed|
  Feed.create(feed)
end

# AdminUser.create!(email: 'admin@example.com', password: 'password', password_confirmation: 'password') if Rails.env.development?

puts "Seed data created successfully!"
