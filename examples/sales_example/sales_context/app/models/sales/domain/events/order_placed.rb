# frozen_string_literal: true

module Sales
  module Domain
    module Events
      # OrderPlaced Domain Event
      # Published when an order is successfully placed in the Sales context
      class OrderPlaced
        attr_reader :order_id, :customer_id, :total_amount, :order_date, :occurred_at

        # Initialize a new OrderPlaced event
        # @param order_id [String] UUID of the order
        # @param customer_id [String] ID of the customer
        # @param total_amount [BigDecimal] Total amount of the order
        # @param order_date [DateTime] When the order was placed
        # @param occurred_at [DateTime] When the event occurred (defaults to now)
        def initialize(order_id:, customer_id:, total_amount:, order_date:, occurred_at: Time.current)
          @order_id = order_id
          @customer_id = customer_id
          @total_amount = total_amount
          @order_date = order_date
          @occurred_at = occurred_at
        end

        # Convert event to hash representation
        # @return [Hash] Event data as hash
        def to_h
          {
            event_type: 'OrderPlaced',
            event_version: '1.0',
            occurred_at: occurred_at.iso8601,
            data: {
              order_id: order_id,
              customer_id: customer_id,
              total_amount: total_amount.to_s,
              order_date: order_date.iso8601
            }
          }
        end

        # Convert event to JSON
        # @return [String] Event as JSON string
        def to_json(*args)
          to_h.to_json(*args)
        end

        # Event metadata
        # @return [Hash] Event metadata
        def metadata
          {
            aggregate_type: 'Order',
            aggregate_id: order_id,
            event_type: 'domain',
            bounded_context: 'Sales'
          }
        end
      end
    end
  end
end
