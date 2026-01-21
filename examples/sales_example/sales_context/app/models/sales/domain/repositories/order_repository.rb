# frozen_string_literal: true

module Sales
  module Domain
    module Repositories
      # Repository for Order Aggregate
      # Handles persistence operations for Order aggregate root
      class OrderRepository
        class RepositoryError < StandardError; end
        class OrderNotFoundError < RepositoryError; end

        # Save an order
        # @param order [Sales::Domain::Aggregates::Order] The order to save
        # @return [Sales::Domain::Aggregates::Order] The saved order
        def save(order)
          order.save!
          order
        rescue ActiveRecord::RecordInvalid => e
          raise RepositoryError, "Failed to save order: #{e.message}"
        end

        # Find an order by ID
        # @param id [String] UUID of the order
        # @return [Sales::Domain::Aggregates::Order] The order
        def find(id)
          Aggregates::Order.find(id)
        rescue ActiveRecord::RecordNotFound
          raise OrderNotFoundError, "Order with id #{id} not found"
        end

        # Find an order by ID, returns nil if not found
        # @param id [String] UUID of the order
        # @return [Sales::Domain::Aggregates::Order, nil] The order or nil
        def find_by_id(id)
          Aggregates::Order.find_by(id: id)
        end

        # Get all orders
        # @return [Array<Sales::Domain::Aggregates::Order>] All orders
        def all
          Aggregates::Order.all
        end

        # Find orders by customer
        # @param customer_id [String] The customer ID
        # @return [Array<Sales::Domain::Aggregates::Order>] Orders for the customer
        def find_by_customer(customer_id)
          Aggregates::Order.where(customer_id: customer_id)
        end

        # Find orders by status
        # @param status [String] The order status
        # @return [Array<Sales::Domain::Aggregates::Order>] Orders with the given status
        def find_by_status(status)
          Aggregates::Order.where(status: status)
        end

        # Delete an order
        # @param order [Sales::Domain::Aggregates::Order] The order to delete
        # @return [Boolean] True if successful
        def delete(order)
          order.destroy!
          true
        rescue ActiveRecord::RecordNotDestroyed => e
          raise RepositoryError, "Failed to delete order: #{e.message}"
        end
      end
    end
  end
end
