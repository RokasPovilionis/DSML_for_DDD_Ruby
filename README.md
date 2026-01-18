# DSML_for_DDD_Ruby
A Master's degree project to create a DSML for Ruby

## Thesis Project – End-to-End Overview

This thesis implements an end-to-end, model-driven pipeline for generating Ruby / Ruby on Rails code from Domain-Driven Design (DDD) diagrams using a custom DSML in Draw.io and AI-based code generation.

The solution consists of four main parts:

1. **DSML Stencil (Draw.io library)**
   A custom diagrams.net / Draw.io library defines visual elements for DDD concepts:
   - Bounded Contexts, Aggregates, Entities, Value Objects
   - Repositories, Domain Services, Application Services
   - Domain Events, External Systems
   plus typed connectors (composition, association, uses, repository_access, publishes_event, consumes_event, integration).

   Each shape stores semantic metadata (e.g. `ddd_type`, `ddd_name`, `relation_type`), so diagrams are machine-readable.

2. **DSML Models (Drawings produced by the user)**
   The developer uses the DSML library to model the business domain in Draw.io and saves the model as a `.drawio` file.
   These diagrams describe the DDD structure: bounded contexts, aggregates, relationships, services, and events.

3. **Diagram Parser** ✅
   The `.drawio` model is parsed into a structured representation of the domain using a custom Ruby parser:
   - **Nokogiri-based XML parsing** for robust handling of Draw.io files
   - **Metadata extraction** for all DSML properties (ddd_type, ddd_name, bounded_context, etc.)
   - **Graph model** with nodes (DDD concepts) and edges (relationships)
   - **Query API** for accessing parsed elements by type, name, or relationships
   - **60+ RSpec tests** ensuring reliability

   ```bash
   # Test the parser
   ruby parse_diagram.rb examples/sales_example/model.drawio.xml
   cd ddd_diagram_parser && bundle exec rspec
   ```

   See [`ddd_diagram_parser/README.md`](ddd_diagram_parser/README.md) for detailed documentation.

4. **AI-based Code Generation**
   The structured representation is sent to a Large Language Model (LLM) together with generation rules and conventions for Ruby / Rails.
   The LLM produces:
   - Ruby models for aggregates, entities, and value objects
   - domain and application service classes
   - domain event classes
   - optionally repository and integration skeletons

5. **Generated Code as a Starting Point**
   The generated Ruby / Rails code is written into the project (e.g. under `generated/`), where the developer can:
   - review and refine the code,
   - iterate on the DSML model and regenerate if needed,
   - gradually move from model to a working Rails backend.

In summary, the project aims to demonstrate how a DSML for DDD, combined with generative AI, can support rapid yet structured backend development in Ruby / Rails.
