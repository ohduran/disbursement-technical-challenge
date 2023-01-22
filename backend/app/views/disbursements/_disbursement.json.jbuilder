json.extract! disbursement, :id, :amount
json.order do
    json.merchant_id disbursement.order.merchant_id
    json.completed_at disbursement.order.completed_at
  end
