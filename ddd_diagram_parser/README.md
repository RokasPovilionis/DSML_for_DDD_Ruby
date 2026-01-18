# DDD Diagram Parser

A Ruby library for parsing Draw.io diagrams that follow Domain-Driven Design (DDD) conventions into a structured model.

## Features

- **XML Parsing with Nokogiri**: Robust parsing of Draw.io XML files
- **DSML Metadata Extraction**: Extracts DDD-specific properties from diagram elements
- **Graph Representation**: Internal model with nodes (DDD entities) and edges (relationships)
- **Query API**: Convenient methods to query the parsed model by type, name, or relationships
- **Comprehensive Testing**: Full RSpec test suite with 60+ tests

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

### CLI Tool

```bash
ruby parse_diagram.rb examples/sales_example/model.drawio.xml
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
- `aggregate`: Which aggregate the element belongs to (for entities/value objects)
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
├── parser.rb           # Main entry point
├── node.rb             # Node class
├── edge.rb             # Edge class
├── model.rb            # Model class
├── xml_parser.rb       # XML parsing logic
├── metadata_extractor.rb  # Metadata extraction
└── spec/               # Test suite
    ├── spec_helper.rb
    ├── parser_spec.rb
    ├── model_spec.rb
    ├── node_spec.rb
    ├── edge_spec.rb
    └── metadata_extractor_spec.rb
```

## Example

See `examples/sales_example/model.drawio.xml` for a sample DDD diagram with:
- Bounded Context: Sales
- Application Service: PlaceOrder
- Aggregate Root: Order
- Relationship: PlaceOrder uses Order

## Next Steps

The parser provides the foundation for:
1. **Validation Layer**: Enforce DDD/DSML rules (Phase 2)
2. **Code Generation**: Generate Ruby/Rails code from diagrams
3. **AI Integration**: Only proceed to AI if validation passes

## License

MIT
