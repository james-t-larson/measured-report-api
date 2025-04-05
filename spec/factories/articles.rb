FactoryBot.define do
  factory :article do
    title { Faker::Book.title }
    summary { Faker::Lorem.sentence }
    content { Faker::Lorem.paragraph }
    sources { Faker::Lorem.paragraph }
    category { Category.all.sample }
  end
end
