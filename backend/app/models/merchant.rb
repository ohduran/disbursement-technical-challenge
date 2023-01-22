class Merchant < ApplicationRecord
  attribute :name, :string
  attribute :email, :string
  attribute :cif, :string

  has_many :orders
  has_many :disbursements, through: :orders
end
