FactoryBot.define do
  factory :order do
    merchant
    shopper
    amount { Faker::Number.decimal(l_digits: 2, r_digits: 2) }
    completed_at { nil }

    trait :completed_last_week do
      completed_at { Time.current.beginning_of_week(:wednesday) - 1.week }
    end

    trait :with_disbursement do
      after :create do |order|
        create :disbursement, order: order
      end
    end
  end
end
