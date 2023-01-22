require 'rails_helper'

RSpec.describe Merchant, type: :model do
  describe '#total_disbursement_amount' do
    let(:merchant) { create(:merchant) }
    let!(:outside_scope_disbursement) { create(:disbursement, order: outside_scope_order) }
    let!(:inside_scope_disbursement) { create(:disbursement, order: inside_scope_order) }

    context 'when defining from a to parameters' do
      let(:from) { Time.now - 1.week }
      let(:to) { Time.now }
      let(:outside_scope_order) { create(:order, merchant: merchant, completed_at: to) }
      let(:inside_scope_order) { create(:order, merchant: merchant, completed_at: from + 1.day) }

      it 'calculates the total amount of disbursements for a merchant' do
        total_amount = merchant.total_disbursement_amount(from: from, to: to)
        expect(total_amount).to eq(inside_scope_disbursement.amount)
      end
    end

    context 'when using the default parameters' do
      let(:outside_scope_order) { create(:order, merchant: merchant, completed_at: Time.now.beginning_of_week) }
      let(:inside_scope_order) { create(:order, merchant: merchant, completed_at: Time.now - 1.week) }

      it 'calculates the total amount of disbursements with default values' do
        total_amount = merchant.total_disbursement_amount
        expect(total_amount).to eq(inside_scope_disbursement.amount)
      end
    end
  end
end
