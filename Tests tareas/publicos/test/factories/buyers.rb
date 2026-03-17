FactoryBot.define do
  factory :buyer do
    sequence(:name) { |n| "Buyer #{n}" }
    sequence(:wallet) { |n| 1000 + n }

    trait :with_products do
      transient do
        products_count { 3 }
      end

      after(:create) do |buyer, evaluator|
        products = create_list(:product, :not_available, evaluator.products_count)
        buyer.products << products
      end
    end
  end
end
