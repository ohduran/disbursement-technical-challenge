require 'rails_helper'

RSpec.describe DisbursementsJob, type: :job do
  describe '#perform' do
    let(:merchant) { create(:merchant) }

    before do
      # amount < 50
      create(:order, :completed_last_week, merchant: merchant, amount: 20)

      # 50 <= amount <= 300
      create(:order, :completed_last_week, merchant: merchant, amount: 50)
      create(:order, :completed_last_week, merchant: merchant, amount: 150)
      create(:order, :completed_last_week, merchant: merchant, amount: 300)

      # 300 < amount
      create(:order, :completed_last_week, merchant: merchant, amount: 1000)

      # Orders outside scope: they have disbursements, completed not last week, or not completed
      @out_of_scope_orders = []
      @out_of_scope_orders.concat(create_list(:order, 5, :completed_last_week, :with_disbursement, merchant: merchant))
      @out_of_scope_orders.concat(create_list(:order, 5, completed_at: Time.now, merchant: merchant))
      @out_of_scope_orders.concat(create_list(:order, 5, completed_at: nil, merchant: merchant))
    end

    it 'calculates the disbursement amount only for the eligible orders' do
      expect(Disbursement).to receive(:create!).with(have_attributes(length: 5))
      DisbursementsJob.perform_now
    end

    it 'calculates the correct disbursement amount for each order' do
      DisbursementsJob.perform_now
      expect(
        Disbursement.joins(:order)
        .where.not(order: @out_of_scope_orders)
        .map(&:amount)
      ).to eq([
                0.2, # 1% fee for amounts smaller than 50 €
                0.475,  # 0.95% for amounts between 50€ - 300€
                1.425,  # 0.95% for amounts between 50€ - 300€
                2.85, # 0.95% for amounts between 50€ - 300€
                8.5  # 0.85% for amounts over 300€
              ])
    end
  end
end
