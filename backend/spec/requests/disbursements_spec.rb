require 'rails_helper'

RSpec.describe DisbursementsController, type: :request do
  describe 'GET /disbursements' do
    let(:parsed_json) { JSON.parse(response.body) }

    let(:merchant) { create(:merchant) }
    let!(:merchant_orders_completed_last_week) do
      create_list(:order, 3, :with_disbursement, :completed_last_week, merchant: merchant)
    end
    let!(:merchant_orders_completed_today) do
      create_list(:order, 4, :with_disbursement, completed_at: Time.now, merchant: merchant)
    end

    let(:another_merchant) { create(:merchant) }
    let!(:another_merchant_orders_completed_last_week) do
      create_list(:order, 3, :with_disbursement, :completed_last_week, merchant: another_merchant)
    end
    let!(:another_merchant_orders_completed_today) do
      create_list(:order, 4, :with_disbursement, completed_at: Time.now, merchant: another_merchant)
    end

    context 'when no parameters are provided' do
      let(:url) { disbursements_url }
      it 'should return a successful response' do
        get(url)
        expect(response).to have_http_status(:ok)
      end

      it 'should list all disbursements for orders completed last week' do
        get(url)
        expect(parsed_json.pluck('id'))
          .to eq(
            (merchant_orders_completed_last_week + another_merchant_orders_completed_last_week)
            .map { |order| order.disbursement.id }
          )
      end

      it 'should have the correct format' do
        get(url)
        parsed_json.each do |disbursement_data|
          expect(disbursement_data).to have_key('id')
          expect(disbursement_data).to have_key('amount')
          expect(disbursement_data).to have_key('order')

          expect(disbursement_data['order']).to have_key('merchant_id')
          expect(disbursement_data['order']).to have_key('completed_at')
        end
      end
    end

    context 'when merchant_id is provided' do
      let(:url) { disbursements_url(merchant_id: merchant.id) }
      context 'and it matches a merchant' do
        it 'should return a successful response' do
          get(url)
          expect(response).to have_http_status(:ok)
        end

        it 'should list all disbursements for orders completed last week for that merchant' do
          get(url)
          expect(parsed_json.pluck('id'))
            .to eq(
              merchant_orders_completed_last_week
              .map { |order| order.disbursement.id }
            )
        end
      end

      context 'and it does not match a merchant' do
        let(:url) { disbursements_url(merchant_id: 999) }
        it 'should return a successful response' do
          get(url)
          expect(response).to have_http_status(:bad_request)
        end
      end
    end

    context 'when time parameters are given' do
      let(:url) { disbursements_url(start_time: start_time, end_time: end_time) }

      context 'and are valid' do
        let(:start_time) { Time.current.beginning_of_week }
        let(:end_time) { Time.current.end_of_week }

        it 'should return a successful response' do
          get(url)
          expect(response).to have_http_status(:ok)
        end

        it 'should list all disbursements for orders completed during that timeframe' do
          get(url)
          expect(parsed_json.pluck('id'))
            .to eq(
              (merchant_orders_completed_today + another_merchant_orders_completed_today)
              .map { |order| order.disbursement.id }
            )
        end
      end

      context 'and are not valid' do
        let(:start_time) { 'Test' }
        let(:end_time) { 'Test' }

        it 'should return a bad request response' do
          get(url)
          expect(response).to have_http_status(:bad_request)
        end
      end

      context 'but only one is given' do
        let(:start_time) { Time.current.beginning_of_week }
        let(:end_time) { nil }

        it 'should return a bad request response' do
          get(url)
          expect(response).to have_http_status(:bad_request)
        end
      end
    end
  end
end
