# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Sales::Domain::Aggregates::Order, type: :model do
  describe '.create_new' do
    it 'creates a new order with draft status' do
      order = described_class.create_new(
        customer_id: 'customer-123',
        total_amount: 100.00
      )

      expect(order.id).to be_present
      expect(order.status).to eq('draft')
      expect(order.customer_id).to eq('customer-123')
      expect(order.total_amount).to eq(100.00)
    end
  end

  describe '#place' do
    let(:order) { described_class.create_new(customer_id: 'customer-123', total_amount: 100.00) }

    it 'places the order' do
      order.place

      expect(order.status).to eq('placed')
      expect(order.order_date).to be_present
      expect(order.persisted?).to be true
    end

    it 'raises error if order is already placed' do
      order.place

      expect { order.place }.to raise_error(
        Sales::Domain::Aggregates::Order::DomainError,
        'Order cannot be placed'
      )
    end
  end

  describe '#placed?' do
    it 'returns true for placed orders' do
      order = described_class.create_new(customer_id: 'customer-123', total_amount: 100.00)
      order.place

      expect(order.placed?).to be true
    end

    it 'returns false for draft orders' do
      order = described_class.create_new(customer_id: 'customer-123', total_amount: 100.00)

      expect(order.placed?).to be false
    end
  end
end
