FactoryBot.define do
  factory :brand do
    sequence(:name) { |n| "Brand #{n}" }
    sequence(:country) { |n| "Country #{n}" }

    trait :with_products do
      transient do
        products_count { 3 }
      end

      after(:create) do |brand, evaluator|
        create_list(:product, evaluator.products_count, brand: brand)
      end
    end
  end
end