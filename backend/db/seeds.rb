# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: "Star Wars" }, { name: "Lord of the Rings" }])
#   Character.create(name: "Luke", movie: movies.first)

require 'json'

merchants_data = JSON.parse(File.read('db/fixtures/merchants.json'))
merchants_data['RECORDS'].each do |merchant_data|
  Merchant.create!(merchant_data)
end
p "Created #{Merchant.count} merchants"

shoppers_data = JSON.parse(File.read('db/fixtures/shoppers.json'))
shoppers_data['RECORDS'].each do |shopper_data|
  Shopper.create!(shopper_data)
end
p "Created #{Shopper.count} shoppers"

orders_data = JSON.parse(File.read('db/fixtures/orders.json'))
orders_data['RECORDS'].each do |order_data|
  Order.create!(order_data)
end
p "Created #{Order.count} orders"
