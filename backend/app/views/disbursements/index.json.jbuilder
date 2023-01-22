json.array! @disbursements do |disbursement|
  json.partial! 'disbursement', disbursement: disbursement
end
