# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Sales::Domain::Repositories::OrderRepository do
  let(:repository) { described_class.new }
  let(:order_attributes) do
    {
      customer_id: 'customer-123',
      total_amount: 100.50
    }
  end

  describe '#save' do
    it 'saves an order successfully' do
      order = Sales::Domain::Aggregates::Order.create_new(order_attributes)
      
      result = repository.save(order)
      
      expect(result).to eq(order)
      expect(result).to be_persisted
      expect(result.id).to be_present
    end

    it 'raises RepositoryError when save fails' do
      order = Sales::Domain::Aggregates::Order.new
      
      expect {
        repository.save(order)
      }.to raise_error(Sales::Domain::Repositories::OrderRepository::RepositoryError)
    end
  end

  describe '#find' do
    it 'finds an order by id' do
      order = Sales::Domain::Aggregates::Order.create_new(order_attributes)
      repository.save(order)
      
      found_order = repository.find(order.id)
      
      expect(found_order).to eq(order)
      expect(found_order.id).to eq(order.id)
    end

    it 'raises OrderNotFoundError when order does not exist' do
      expect {
        repository.find('non-existent-id')
      }.to raise_error(Sales::Domain::Repositories::OrderRepository::OrderNotFoundError)
    end
  end

  describe '#find_by_id' do
    it 'returns order when found' do
      order = Sales::Domain::Aggregates::Order.create_new(order_attributes)
      repository.save(order)
      
      found_order = repository.find_by_id(order.id)
      
      expect(found_order).to eq(order)
    end

    it 'returns nil when order does not exist' do
      result = repository.find_by_id('non-existent-id')
      
      expect(result).to be_nil
    end
  end

  describe '#all' do
    it 'returns all orders' do
      order1 = Sales::Domain::Aggregates::Order.create_new(order_attributes)
      order2 = Sales::Domain::Aggregates::Order.create_new(order_attributes.merge(customer_id: 'customer-456'))
      
      repository.save(order1)
      repository.save(order2)
      
      all_orders = repository.all
      
      expect(all_orders).to include(order1, order2)
    end
  end

  describe '#find_by_customer' do
    it 'returns orders for a specific customer' do
      customer_id = 'customer-123'
      order1 = Sales::Domain::Aggregates::Order.create_new(order_attributes.merge(customer_id: customer_id))
      order2 = Sales::Domain::Aggregates::Order.create_new(order_attributes.merge(customer_id: 'customer-456'))
      
      repository.save(order1)
      repository.save(order2)
      
      customer_orders = repository.find_by_customer(customer_id)
      
      expect(customer_orders).to include(order1)
      expect(customer_orders).not_to include(order2)
    end
  end

  describe '#find_by_status' do
    it 'returns orders with specific status' do
      order1 = Sales::Domain::Aggregates::Order.create_new(order_attributes)
      order2 = Sales::Domain::Aggregates::Order.create_new(order_attributes)
      
      repository.save(order1)
      order1.place
      repository.save(order1)
      
      repository.save(order2)
      
      placed_orders = repository.find_by_status('placed')
      draft_orders = repository.find_by_status('draft')
      
      expect(placed_orders).to include(order1)
      expect(placed_orders).not_to include(order2)
      expect(draft_orders).to include(order2)
    end
  end

  describe '#delete' do
    it 'deletes an order successfully' do
      order = Sales::Domain::Aggregates::Order.create_new(order_attributes)
      repository.save(order)
      
      result = repository.delete(order)
      
      expect(result).to be true
      expect(repository.find_by_id(order.id)).to be_nil
    end
  end
end
