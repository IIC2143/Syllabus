FactoryBot.define do
  factory :calendar do
    sequence(:name) { |n| "Calendar_#{n}" }
    description { "Default calendar description" }

    trait :with_events do
      transient do
        events_count { 3 }
      end

      after(:create) do |calendar, evaluator|
        create_list(:event, evaluator.events_count, calendar: calendar)
      end
    end
  end
end
