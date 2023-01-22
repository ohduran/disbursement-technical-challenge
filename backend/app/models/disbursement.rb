class Disbursement < ApplicationRecord
  delegate :merchant, to: :order
  belongs_to :order

  attribute :amount, :decimal
end
