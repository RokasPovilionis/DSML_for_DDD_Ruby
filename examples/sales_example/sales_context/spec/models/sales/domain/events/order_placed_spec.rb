# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Sales::Domain::Events::OrderPlaced do
  let(:order_id) { SecureRandom.uuid }
  let(:customer_id) { 'customer-123' }
  let(:total_amount) { BigDecimal('100.50') }
  let(:order_date) { Time.current }
  let(:occurred_at) { Time.current }

  let(:event) do
    described_class.new(
      order_id: order_id,
      customer_id: customer_id,
      total_amount: total_amount,
      order_date: order_date,
      occurred_at: occurred_at
    )
  end

  describe '#initialize' do
    it 'sets all attributes correctly' do
      expect(event.order_id).to eq(order_id)
      expect(event.customer_id).to eq(customer_id)
      expect(event.total_amount).to eq(total_amount)
      expect(event.order_date).to eq(order_date)
      expect(event.occurred_at).to eq(occurred_at)
    end

    it 'defaults occurred_at to current time if not provided' do
      event_without_time = described_class.new(
        order_id: order_id,
        customer_id: customer_id,
        total_amount: total_amount,
        order_date: order_date
      )

      expect(event_without_time.occurred_at).to be_within(1.second).of(Time.current)
    end
  end

  describe '#to_h' do
    it 'returns a hash representation of the event' do
      hash = event.to_h

      expect(hash[:event_type]).to eq('OrderPlaced')
      expect(hash[:event_version]).to eq('1.0')
      expect(hash[:occurred_at]).to eq(occurred_at.iso8601)
      expect(hash[:data][:order_id]).to eq(order_id)
      expect(hash[:data][:customer_id]).to eq(customer_id)
      expect(hash[:data][:total_amount]).to eq(total_amount.to_s)
      expect(hash[:data][:order_date]).to eq(order_date.iso8601)
    end
  end

  describe '#to_json' do
    it 'returns a JSON representation of the event' do
      json = event.to_json
      parsed = JSON.parse(json)

      expect(parsed['event_type']).to eq('OrderPlaced')
      expect(parsed['data']['order_id']).to eq(order_id)
      expect(parsed['data']['customer_id']).to eq(customer_id)
    end
  end

  describe '#metadata' do
    it 'returns event metadata' do
      metadata = event.metadata

      expect(metadata[:aggregate_type]).to eq('Order')
      expect(metadata[:aggregate_id]).to eq(order_id)
      expect(metadata[:event_type]).to eq('domain')
      expect(metadata[:bounded_context]).to eq('Sales')
    end
  end
end
