# frozen_string_literal: true

class CreateSalesOrders < ActiveRecord::Migration[7.1]
  def change
    # Enable UUID extension
    enable_extension 'pgcrypto' unless extension_enabled?('pgcrypto')

    create_table :sales_orders, id: :uuid do |t|
      t.string :customer_id
      t.string :status, null: false, default: 'draft'
      t.decimal :total_amount, precision: 10, scale: 2, default: 0.0
      t.datetime :order_date

      t.timestamps
    end

    add_index :sales_orders, :status
    add_index :sales_orders, :customer_id
    add_index :sales_orders, :order_date
  end
end
