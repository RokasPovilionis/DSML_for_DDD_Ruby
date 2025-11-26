# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::V1::Sales::OrdersController, type: :controller do
  describe 'POST #create' do
    context 'with valid parameters' do
      let(:valid_params) do
        {
          order: {
            customer_id: 'customer-123',
            total_amount: 99.99
          }
        }
      end

      it 'creates a new order' do
        post :create, params: valid_params

        expect(response).to have_http_status(:created)
        json_response = JSON.parse(response.body)
        expect(json_response['customer_id']).to eq('customer-123')
        expect(json_response['total_amount']).to eq('99.99')
        expect(json_response['status']).to eq('placed')
      end
    end

    context 'with invalid parameters' do
      let(:invalid_params) do
        {
          order: {
            customer_id: '',
            total_amount: 99.99
          }
        }
      end

      it 'returns unprocessable entity' do
        post :create, params: invalid_params

        expect(response).to have_http_status(:unprocessable_entity)
        json_response = JSON.parse(response.body)
        expect(json_response['error']).to be_present
      end
    end
  end

  describe 'GET #show' do
    let!(:order) do
      Sales::Domain::Aggregates::Order.create_new(
        customer_id: 'customer-123',
        total_amount: 99.99
      ).tap(&:place)
    end

    it 'returns the order' do
      get :show, params: { id: order.id }

      expect(response).to have_http_status(:ok)
      json_response = JSON.parse(response.body)
      expect(json_response['id']).to eq(order.id)
      expect(json_response['customer_id']).to eq('customer-123')
    end

    it 'returns not found for non-existent order' do
      get :show, params: { id: SecureRandom.uuid }

      expect(response).to have_http_status(:not_found)
    end
  end

  describe 'GET #index' do
    before do
      2.times do |i|
        Sales::Domain::Aggregates::Order.create_new(
          customer_id: "customer-#{i}",
          total_amount: 50.00 * (i + 1)
        ).tap(&:place)
      end
    end

    it 'returns all orders' do
      get :index

      expect(response).to have_http_status(:ok)
      json_response = JSON.parse(response.body)
      expect(json_response.length).to eq(2)
    end
  end
end
