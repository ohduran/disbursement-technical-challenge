FactoryBot.define do
  factory :disbursement do
    amount { Faker::Number.decimal(l_digits: 2, r_digits: 2) }
    order
  end
end
