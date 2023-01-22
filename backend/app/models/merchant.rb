class Merchant < ApplicationRecord
  attribute :name, :string
  attribute :email, :string
  attribute :cif, :string

  has_many :orders
  has_many :disbursements, through: :orders

  def total_disbursement_amount(from: Time.now.beginning_of_week - 1.week, to: Time.now.beginning_of_week)
    orders = self.orders.where(completed_at: from...to)
    disbursements.where(order_id: orders.pluck(:id)).sum(:amount)
  end
end
