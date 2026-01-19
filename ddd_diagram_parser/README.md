# DDD Diagram Parser

A Ruby library for parsing Draw.io diagrams that follow Domain-Driven Design (DDD) conventions into a structured model.

## Features

- **XML Parsing with Nokogiri**: Robust parsing of Draw.io XML files
- **DSML Metadata Extraction**: Extracts DDD-specific properties from diagram elements
- **Graph Representation**: Internal model with nodes (DDD entities) and edges (relationships)
- **Query API**: Convenient methods to query the parsed model by type, name, or relationships
- **Validation Framework**: 10 validation rules (R1-R10) enforcing DSML and DDD constraints
- **Comprehensive Testing**: Full RSpec test suite with 110+ tests

## Installation

```bash
cd ddd_diagram_parser
bundle install
```

## Usage

### As a Library

```ruby
require_relative 'ddd_diagram_parser/parser'

# Parse a diagram file
model = DddDiagramParser::Parser.parse('path/to/diagram.drawio.xml')

# Query the model
bounded_contexts = model.nodes_by_type('bounded_context')
aggregates = model.nodes_by_type('aggregate_root')

# Get properties
aggregate = aggregates.first
puts aggregate.ddd_name
puts aggregate['id_type']
puts aggregate['bounded_context']

# Query relationships
edges_from_service = model.edges_from(service_node.id)
```

### Validation

```ruby
require_relative 'ddd_diagram_parser/parser'
require_relative 'ddd_diagram_parser/validator'

# Parse and validate
model = DddDiagramParser::Parser.parse('path/to/diagram.drawio.xml')
report = DddDiagramParser::Validator.validate(model)

**Parsing:**
- **`Node`**: Represents DDD concepts (BoundedContext, Aggregate, Entity, Service, etc.)
- **`Edge`**: Represents relationships (uses, composition, publishes, etc.)
- **`Model`**: Container for nodes and edges with query capabilities
- **`XmlParser`**: Low-level XML parsing using Nokogiri
- **`MetadataExtractor`**: Extracts and normalizes DSML metadata
- **`Parser`**: Main orchestrator that coordinates parsing

**Validation:**
- **`ValidationReport`**: Container for validation errors and warnings
- **`ValidationIssue`**: Individual validation error or warning
- **`Validator`**: Main validator orchestrator
- **Validators (R1-R10)**: Individual rule validators for each constraint

### CLI Tool

```bash
# Parse only
ruby parse_diagram.rb examples/sales_example/model.drawio.xml

# Parse and validate
ruby parse_diagram.rb examples/sales_example/model.drawio.xml --validate
```

## Architecture

### Core Components

- **`Node`**: Represents DDD concepts (BoundedContext, Aggregate, Entity, Service, etc.)
- **`Edge`**: Represents relationships (uses, composition, publishes, etc.)
- **`Model`**: Container for nodes and edges with query capabilities
- **`XmlParser`**: Low-level XML parsing using Nokogiri
- **`MetadataExtractor`**: Extracts and normalizes DSML metadata
- **`Parser`**: Main orchestrator that coordinates parsing

### Supported DSML Properties

**Node Properties:**
- `ddd_type`: Type of DDD element (bounded_context, aggregate_root, entity, value_object, application_service, domain_service, repository, domain_event, external_system)
- `ddd_name`: Name of the element
- `bounded_context`: Which bounded context the element belongs to
- `aggregate`: Which aggregate the element belongs to (for entities/v_event, consumes_event, integration, repository_access)

## Validation Rules

The parser includes a comprehensive validation framework that enforces DSML and DDD constraints:

**R1: Required Fields**
- Every node must have `ddd_type` and `ddd_name`
- Error codes: `R1_MISSING_DDD_TYPE`, `R1_MISSING_DDD_NAME`

**R2: Uniqueness Constraints**
- Bounded Context names must be globally unique
- Within each Bounded Context: Aggregate, Service, and Event names must be unique
- Error codes: `R2_DUPLICATE_BOUNDED_CONTEXT`, `R2_DUPLICATE_AGGREGATE`, `R2_DUPLICATE_SERVICE`, `R2_DUPLICATE_EVENT`

**R3: Required Properties by Type**
- Each node type has specific required properties:
  - `bounded_context` → `context_key`
  - `aggregate_root` → `bounded_context`, `id_type`
  - `entity` → `aggregate`, `id_type`
  - `value_object` → `aggregate`
  - `repository` → `aggregate`
  - `application_service` → `bounded_context`
  - `domain_service` → `bounded_context`
  - `domain_event` → `bounded_context`
- Error code: `R3_MISSING_REQUIRED_PROPERTY`
      # Dependencies
├── .rspec                    # RSpec configuration
├── parser.rb                 # Main entry point
├── node.rb                   # Node class
├── edge.rb                   # Edge class
├── model.rb                  # Model class with query API
├── xml_parser.rb             # XML parsing logic
├── metadata_extractor.rb     # Metadata extraction
├── validation_report.rb      # ValidationReport & ValidationIssue
├── validator.rb              # Main validator orchestrator
├── validators/               # Individual rule validators
│   ├── required_fields_validator.rb      # R1
│   ├── uniqueness_validator.rb           # R2
│   ├── required_properties_validator.rb  # R3
│   ├── relation_type_validator.rb        # R4
│   ├── composition_validator.rb          # R5
│   ├── publishes_event_validator.rb      # R6
│   ├── consumes_event_validator.rb       # R7
│   ├── repository_access_validator.rb    # R8
│   ├── integration_validator.rb          # R9
│   ├── uses_validator.rb                 # R10
│   ├── aggregate_ownership_validator.rb   # R11
│   ├── bounded_context_membership_validator.rb # R12
│   ├── event_ownership_validator.rb      # R13
│   └── cross_context_validator.rb        # R14
└── spec/                     # Test suite (134+ tests)
    ├── spec_helper.rb
    ├── parser_spec.rb
    ├── model_spec.rb
    ├── node_spec.rb
    ├── edge_spec.rb
    ├── metadata_extractor_spec.rb
    ├── validation_report_spec.rb
    ├── validator_spec.rb
    └── validators/
        ├── relation_type_validator_spec.rb
        ├── composition_validator_spec.rb
        ├── publishes_event_validator_spec.rb
        ├── consumes_event_validator_spec.rb
        ├── repository_access_validator_spec.rb
        ├── integration_validator_spec.rb
        └── uses_validaionships must have:
  - Source: `aggregate_root`
  - Target: `domain_event`
- Error codes: `R6_INVALID_PUBLISHES_SOURCE`, `R6_INVALID_PUBLISHES_TARGET`

**R7: Consumes Event Rules**
- Consumes event relationships must have:
  - Source: `domain_event`
  - Target: `application_service` or `domain_service`
- Error codes: `R7_INVALID_CONSUMES_SOURCE`, `R7_INVALID_CONSUMES_TARGET`

**R8: Repository Access Rules**
- Repository access relationships must have:
  - Source: `application_service` or `domain_service`
  - Target: `repository`
- Error codes: `R8_INVALID_REPOSITORY_ACCESS_SOURCE`, `R8_INVALID_REPOSITORY_ACCESS_TARGET`

**R9: Integration Rules**
- Integration relationships must have:
  - Target: `external_system` (required)
  - Source: typically `application_service` or `bounded_context` (warning if other types)
- Error code: `R9_INVALID_INTEGRATION_TARGET`
- Warning code: `R9_UNUSUAL_INTEGRATION_SOURCE`

**R10: Uses Rules**
- Uses relationships have allowed and disallowed targets:
  - Allowed: `aggregate_root`, `application_service`, `domain_service`, `repository`
  - Disallowed: `value_object`, `domain_event`
  - Other types generate warnings
- Error code: `R10_ILLEGAL_USES_TARGET`
- Warning code: `R10_UNUSUAL_USES_TARGET`

**R11: Entity and Value Object Ownership**
- Every `entity` and `value_object` must belong to an `aggregate_root`
- Validated through:
  - `aggregate` property pointing to the owning aggregate
  - Incoming `composition` edge from that aggregate
- Error if both property and edge are missing
- Warning if only one exists (property without edge, or edge without property)
- Error if referenced aggregate doesn't exist
- Error if property and edge reference different aggregates
- Error codes: `R11_MISSING_AGGREGATE_OWNERSHIP`, `R11_INVALID_AGGREGATE_REFERENCE`, `R11_AGGREGATE_MISMATCH`
- Warning codes: `R11_MISSING_AGGREGATE_PROPERTY`, `R11_MISSING_COMPOSITION_EDGE`

**R12: Aggregate Bounded Context Membership**
- Every `aggregate_root` must belong to exactly one `bounded_context`
- Validated through `bounded_context` property
- Error if property is missing or empty
- Error if referenced bounded context doesn't exist
- Error codes: `R12_MISSING_BOUNDED_CONTEXT`, `R12_INVALID_BOUNDED_CONTEXT`

**R13: Domain Event Ownership**
- Every `domain_event` must belong to exactly one `bounded_context`
- Should be published by exactly one `aggregate_root` (via `publishes_event`)
- Error if `bounded_context` property missing or invalid
- Warning if event is not published by any aggregate
- Error if event is published by multiple aggregates
- Error codes: `R13_MISSING_BOUNDED_CONTEXT`, `R13_INVALID_BOUNDED_CONTEXT`, `R13_MULTIPLE_EVENT_PUBLISHERS`
- Warning codes: `R13_EVENT_NOT_PUBLISHED`

**R14: Cross-Bounded-Context Relationships**
- Detects relationships that cross bounded context boundaries
- Rules by relationship type:
  - `integration` → Allowed (no error/warning)
  - `composition`, `association` → **Error** (violates DDD aggregate boundaries)
  - `repository_access` → **Error** (repositories are context-private)
  - `uses`, `publishes_event`, `consumes_event` → **Warning** (needs careful design)
- Error codes: `R14_CROSS_CONTEXT_COMPOSITION`, `R14_CROSS_CONTEXT_REPOSITORY`
- Warning codes: `R14_CROSS_CONTEXT_USES`, `R14_CROSS_CONTEXT_EVENT`

### Validation Report Format

```
Validation Report:
============================================================
Errors: 2, Warnings: 1
============================================================
ERROR R1_MISSING_DDD_TYPE: Node must have a ddd_type property
  Node: Order (node123)
ERROR R5_INVALID_COMPOSITION_SOURCE: Composition source must be aggregate_root, found 'entity'
  Node: LineItem -> Product (edge456)
WARNING R9_UNUSUAL_INTEGRATION_SOURCE: Integration source is typically application_service or bounded_context, found 'entity'
  Node: Order -> PaymentGateway (edge789)
============================================================
✗ Validation failed
```
- `context_key`: Snake_case key for bounded context
- `id_type`: Type of identifier (uuid, integer, string)
- `rails_resource`: Boolean indicating if it's a Rails resource
- `exposed_as`: How a service is exposed (rest, grpc, etc.)

**Edge Properties:**
- `relation_type`: Type of relationship (uses, composition, publishes, consumes, integration, repository_access)

## Testing

Run the test suite:

```bash
cd ddd_diagram_parser
bundle exec rspec
```

Run specific tests:

```bash
bundle exec rspec spec/parser_spec.rb
```

## Project Structure

```
ddd_diagram_parser/
├── Gemfile              # Dependencies
├── .rspec              # RSpec configuration
├──Development Status

**Completed:**
- XML parsing with Nokogiri
- DSML metadata extraction
- Graph model with query API
- Validation framework (R1-R14)
- 134+ RSpec tests, all passing

## Example

See `examples/sales_example/model.drawio.xml` for a sample DDD diagram with:
- Bounded Context: Sales
- Application Service: PlaceOrder
- Aggregate Root: Order
- Relationship: PlaceOrder uses Order

## License

MIT
