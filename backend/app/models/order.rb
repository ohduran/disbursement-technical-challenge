class Order < ApplicationRecord
  belongs_to :merchant
  belongs_to :shopper

  attribute :amount, :decimal
  attribute :completed_at, :datetime

  has_one :disbursement

  # Would not include the orders that were completed on the start of this week
  scope :completed_last_week, lambda {
    where(completed_at: (Time.current.beginning_of_week - 1.week)...Time.current.beginning_of_week)
  }

  scope :not_disbursed, lambda {
    where.not(id: Disbursement.select(:order_id))
  }
end
