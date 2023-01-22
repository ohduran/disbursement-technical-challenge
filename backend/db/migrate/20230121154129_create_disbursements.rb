class CreateDisbursements < ActiveRecord::Migration[7.0]
  def change
    create_table :disbursements do |t|
      t.decimal :amount, :decimal, precision: 10, scale: 2
      t.references :order, null: false, foreign_key: true

      t.timestamps
    end
  end
end
