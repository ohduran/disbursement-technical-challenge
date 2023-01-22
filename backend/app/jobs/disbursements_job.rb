# Calculate the disbursement amount for each order
class DisbursementsJob < ApplicationJob
  queue_as :default

  def perform(*_args)
    disbursements_data = []

    Order.completed_last_week.not_disbursed.find_each do |order|
      amount = calculate_disbursement(order.amount)
      disbursements_data << { order_id: order.id, amount: amount }
    end

    Disbursement.create!(disbursements_data)
  end

  private

  def calculate_disbursement(amount)
    if amount < 50
      amount * 0.01
    elsif amount.between?(50, 300)
      amount * 0.0095
    elsif amount > 300
      amount * 0.0085
    end
  end
end
