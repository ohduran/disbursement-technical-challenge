FactoryBot.define do
  factory :order do
    merchant { nil }
    shopper { nil }
    amount { "9.99" }
    created_at { "2023-01-21 10:29:38" }
    completed_at { "2023-01-21 10:29:38" }
  end
end
