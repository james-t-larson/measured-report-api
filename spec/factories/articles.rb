FactoryBot.define do
  factory :article do
    title { Faker::Book.title }
    category_id { rand(1..5) }
    summary { Faker::Lorem.sentence }
    content { Faker::Lorem.paragraph }
    sources { Faker::Lorem.paragraph }
  end
end
