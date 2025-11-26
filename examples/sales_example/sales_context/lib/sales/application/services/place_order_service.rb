# frozen_string_literal: true

module Sales
  module Application
    module Services
      # PlaceOrder Application Service
      # Handles the business logic for placing orders
      # Exposed as REST API
      class PlaceOrderService
        class PlaceOrderError < StandardError; end
        class ValidationError < PlaceOrderError; end

        # Execute the service
        # @param params [Hash] Order parameters
        # @return [Sales::Domain::Aggregates::Order] The placed order
        def self.call(params)
          new(params).call
        end

        def initialize(params)
          @params = params
          @errors = []
        end

        def call
          validate_params!
          place_order
        rescue ValidationError => e
          raise PlaceOrderError, "Failed to place order: #{e.message}"
        end

        private

        attr_reader :params, :errors

        def validate_params!
          validate_presence(:customer_id, 'Customer ID is required')
          validate_presence(:total_amount, 'Total amount is required')
          validate_positive_amount if params[:total_amount]

          raise ValidationError, errors.join(', ') if errors.any?
        end

        def validate_presence(key, message)
          errors << message if params[key].blank?
        end

        def validate_positive_amount
          amount = params[:total_amount].to_f
          errors << 'Total amount must be positive' if amount <= 0
        end

        def place_order
          order = Sales::Domain::Aggregates::Order.create_new(
            customer_id: params[:customer_id],
            total_amount: params[:total_amount]
          )

          order.place
          order
        end
      end
    end
  end
end
