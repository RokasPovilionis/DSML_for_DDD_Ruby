# frozen_string_literal: true

module Api
  module V1
    module Sales
      # REST API Controller for Orders
      # Exposes the PlaceOrder application service
      class OrdersController < ApplicationController
        # POST /api/v1/sales/orders
        def create
          order = place_order_service.call(order_params)

          render json: order_response(order), status: :created
        rescue ::Sales::Application::Services::PlaceOrderService::PlaceOrderError => e
          render json: { error: e.message }, status: :unprocessable_entity
        end

        # GET /api/v1/sales/orders/:id
        def show
          order = find_order
          render json: order_response(order), status: :ok
        rescue ActiveRecord::RecordNotFound
          render json: { error: 'Order not found' }, status: :not_found
        end

        # GET /api/v1/sales/orders
        def index
          orders = ::Sales::Domain::Aggregates::Order.all.order(created_at: :desc)
          render json: orders.map { |order| order_response(order) }, status: :ok
        end

        private

        def place_order_service
          ::Sales::Application::Services::PlaceOrderService
        end

        def find_order
          ::Sales::Domain::Aggregates::Order.find(params[:id])
        end

        def order_params
          params.require(:order).permit(:customer_id, :total_amount)
        end

        def order_response(order)
          {
            id: order.id,
            customer_id: order.customer_id,
            status: order.status,
            total_amount: order.total_amount,
            order_date: order.order_date,
            created_at: order.created_at,
            updated_at: order.updated_at
          }
        end
      end
    end
  end
end
