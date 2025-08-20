FactoryBot.define do
  factory :event do
    association :calendar
    sequence(:title) { |n| "Event #{n}" }
    description { "Default event description" }
    date { Time.zone.now + 1.day }

    trait :past_event do
      date { Time.zone.now - 1.day }
    end

    trait :future_event do
      date { Time.zone.now + 7.days }
    end
  end
end
