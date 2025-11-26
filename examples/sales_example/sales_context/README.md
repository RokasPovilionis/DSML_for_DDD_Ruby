# Sales Bounded Context - Ruby on Rails Application

This is a Ruby on Rails application implementing the Sales bounded context following Domain-Driven Design (DDD) principles.

## Architecture

### Bounded Context: Sales
- **Context Key**: `sales`
- **Purpose**: Manages order placement and order lifecycle

### Domain Model

#### Aggregate Root: Order
- **ID Type**: UUID
- **Attributes**:
  - `id` (UUID, primary key)
  - `customer_id` (String)
  - `status` (String: draft, placed)
  - `total_amount` (Decimal)
  - `order_date` (DateTime)
  - `created_at` (DateTime)
  - `updated_at` (DateTime)

- **Location**: `app/models/sales/domain/aggregates/order.rb`

#### Application Service: PlaceOrderService
- **Purpose**: Handles the business logic for placing orders
- **Exposed As**: REST API
- **Location**: `lib/sales/application/services/place_order_service.rb`

### REST API Endpoints

**Base URL**: `/api/v1/sales`

#### Create Order (Place Order)
```
POST /api/v1/sales/orders
Content-Type: application/json

{
  "order": {
    "customer_id": "customer-123",
    "total_amount": 99.99
  }
}
```

#### Get Order
```
GET /api/v1/sales/orders/:id
```

#### List Orders
```
GET /api/v1/sales/orders
```

## Setup Instructions

### Prerequisites
- Ruby ~> 3.2.0
- PostgreSQL 12+
- Bundler

### Installation

1. Install dependencies:
```bash
bundle install
```

2. Setup database:
```bash
bin/rails db:create
bin/rails db:migrate
```

3. Start the server:
```bash
bin/rails server
```

The application will be available at `http://localhost:3000`

## Project Structure

```
sales_context/
├── app/
│   ├── controllers/
│   │   ├── application_controller.rb
│   │   └── api/v1/sales/
│   │       └── orders_controller.rb      # REST API endpoints
│   └── models/
│       ├── application_record.rb
│       └── sales/domain/aggregates/
│           └── order.rb                   # Order Aggregate Root
├── lib/
│   └── sales/application/services/
│       └── place_order_service.rb         # PlaceOrder Application Service
├── config/
│   ├── application.rb
│   ├── database.yml
│   ├── routes.rb
│   └── ...
├── db/
│   ├── migrate/
│   │   └── 20241126000001_create_sales_orders.rb
│   └── schema.rb
├── Gemfile
└── README.md
```

## DDD Implementation

This application follows DDD tactical patterns:

- **Bounded Context**: Clear boundary for the Sales domain
- **Aggregate Root**: Order entity with UUID identity
- **Application Service**: PlaceOrderService coordinates domain logic
- **Domain Model**: Rich domain model with business logic
- **Infrastructure**: Rails controllers expose REST API

## Testing

Run tests with:
```bash
bundle exec rspec
```

## Development

### Database Console
```bash
bin/rails dbconsole
```

### Rails Console
```bash
bin/rails console
```

### Routes
```bash
bin/rails routes
```

## License

This is a sample application for educational purposes.
