FactoryBot.define do
  factory :user do
    sequence(:name) { |n| "User_#{n}" }
    sequence(:email) { |n| "user#{n}@example.com" }

    trait :with_subscriptions do
      transient do
        calendars_count { 2 }
      end

      after(:create) do |user, evaluator|
        calendars = create_list(:calendar, evaluator.calendars_count)
        user.calendars << calendars
      end
    end
  end
end
