require 'rails_helper'

RSpec.describe Order, type: :model do
  describe '.completed_last_week' do
    let!(:completed_orders) { create_list(:order, 3, completed_at: Time.current.beginning_of_week - 1.week) }
    let!(:completed_orders_not_on_last_week) do
      create_list(:order, 2, completed_at: Time.current.beginning_of_week - 2.week)
    end
    let!(:not_completed_orders) { create_list(:order, 2) }

    it 'returns last week completed orders' do
      expect(Order.completed_last_week).to match_array(completed_orders)
    end
  end
end
