# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Sales::Application::Services::PlaceOrderService do
  describe '.call' do
    context 'with valid parameters' do
      let(:params) do
        {
          customer_id: 'customer-123',
          total_amount: 99.99
        }
      end

      it 'creates and places an order' do
        order = described_class.call(params)

        expect(order).to be_a(Sales::Domain::Aggregates::Order)
        expect(order.customer_id).to eq('customer-123')
        expect(order.total_amount).to eq(99.99)
        expect(order.status).to eq('placed')
        expect(order.order_date).to be_present
        expect(order.persisted?).to be true
      end

      it 'uses repository to save the order' do
        repository = instance_double(Sales::Domain::Repositories::OrderRepository)
        allow(repository).to receive(:save) { |order| order.save!; order }

        order = described_class.call(params, repository: repository)

        expect(repository).to have_received(:save)
        expect(order.persisted?).to be true
      end

      it 'processes domain events' do
        allow(Rails.logger).to receive(:info)

        order = described_class.call(params)

        expect(Rails.logger).to have_received(:info).with(/Domain Event Published/)
        expect(order.domain_events).to be_empty
      end
    end

    context 'with invalid parameters' do
      it 'raises error when customer_id is missing' do
        params = { total_amount: 99.99 }

        expect { described_class.call(params) }.to raise_error(
          Sales::Application::Services::PlaceOrderService::PlaceOrderError,
          /Customer ID is required/
        )
      end

      it 'raises error when total_amount is missing' do
        params = { customer_id: 'customer-123' }

        expect { described_class.call(params) }.to raise_error(
          Sales::Application::Services::PlaceOrderService::PlaceOrderError,
          /Total amount is required/
        )
      end

      it 'raises error when total_amount is not positive' do
        params = { customer_id: 'customer-123', total_amount: -10 }

        expect { described_class.call(params) }.to raise_error(
          Sales::Application::Services::PlaceOrderService::PlaceOrderError,
          /Total amount must be positive/
        )
      end
    end
  end
end
