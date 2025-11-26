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

        # Domain methods
        def place
          # Business logic for placing an order
          raise DomainError, 'Order cannot be placed' if placed?

          self.status = 'placed'
          self.order_date = Time.current
          save!
        end

        def placed?
          status == 'placed'
        end

        # Factory method
        def self.create_new(attributes = {})
          new(attributes.merge(id: SecureRandom.uuid, status: 'draft'))
        end

        class DomainError < StandardError; end
      end
    end
  end
end
