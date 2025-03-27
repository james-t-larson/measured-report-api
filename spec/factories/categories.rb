FactoryBot.define do
  factory :category do
    slug { Faker::Internet.unique.slug }
    name { Faker::Lorem.word }
    position { Faker::Number.unique.between(from: 1, to: 100) }
    created_at { Faker::Time.backward(days: 14) }
    updated_at { Faker::Time.backward(days: 7) }
  end
end
