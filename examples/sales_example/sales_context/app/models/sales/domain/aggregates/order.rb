# frozen_string_literal: true

module Sales
  module Domain
    module Aggregates
      # Order Aggregate Root
      # Represents an order in the Sales bounded context
      class Order < ApplicationRecord
        self.table_name = 'sales_orders'

        # UUID as primary key (configured in model)
        # id: uuid, primary_key: true

        # Attributes
        # Add your order attributes here
        # Example:
        # attribute :customer_id, :uuid
        # attribute :status, :string
        # attribute :total_amount, :decimal
        # attribute :order_date, :datetime

        # Validations
        validates :id, presence: true
        validates :customer_id, presence: true
        validates :total_amount, presence: true, numericality: { greater_than: 0 }

        # Domain Events
        attr_reader :domain_events

        def initialize(*args)
          super
          @domain_events = []
        end

        # Domain methods
        def place
          # Business logic for placing an order
          raise DomainError, 'Order cannot be placed' if placed?

          self.status = 'placed'
          self.order_date = Time.current
          
          # Publish domain event
          publish_event(
            Events::OrderPlaced.new(
              order_id: id,
              customer_id: customer_id,
              total_amount: total_amount,
              order_date: order_date
            )
          )
        end

        def placed?
          status == 'placed'
        end

        # Factory method
        def self.create_new(attributes = {})
          new(attributes.merge(id: SecureRandom.uuid, status: 'draft'))
        end

        # Clear domain events (typically called after events are processed)
        def clear_events
          @domain_events = []
        end

        private

        # Publish a domain event
        # @param event [Object] The domain event to publish
        def publish_event(event)
          @domain_events ||= []
          @domain_events << event
        end

        class DomainError < StandardError; end
      end
    end
  end
end
