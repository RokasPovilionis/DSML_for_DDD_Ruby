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
        # @param repository [Sales::Domain::Repositories::OrderRepository] Optional repository (for testing)
        # @return [Sales::Domain::Aggregates::Order] The placed order
        def self.call(params, repository: nil)
          new(params, repository: repository).call
        end

        def initialize(params, repository: nil)
          @params = params
          @errors = []
          @repository = repository || Sales::Domain::Repositories::OrderRepository.new
        end

        def call
          validate_params!
          place_order
        rescue ValidationError => e
          raise PlaceOrderError, "Failed to place order: #{e.message}"
        end

        private

        attr_reader :params, :errors, :repository

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
          # Create new order using factory method
          order = Sales::Domain::Aggregates::Order.create_new(
            customer_id: params[:customer_id],
            total_amount: params[:total_amount]
          )

          # Execute domain logic
          order.place

          # Persist using repository
          saved_order = repository.save(order)

          # Process domain events
          process_domain_events(saved_order)

          saved_order
        end

        def process_domain_events(order)
          # Here you would typically publish events to an event bus
          # For now, we'll just log them
          order.domain_events.each do |event|
            # In a real application, publish to message broker, event store, etc.
            Rails.logger.info("Domain Event Published: #{event.to_json}")
          end

          # Clear events after processing
          order.clear_events
        end
      end
    end
  end
end
