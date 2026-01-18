# frozen_string_literal: true

# Main module for DDD Diagram Parser
# Provides parsing of Draw.io diagrams into DSML model representations
module DddDiagramParser
  VERSION = '0.1.0'
end

# Require all components
require_relative 'ddd_diagram_parser/node'
require_relative 'ddd_diagram_parser/edge'
require_relative 'ddd_diagram_parser/model'
require_relative 'ddd_diagram_parser/xml_parser'
require_relative 'ddd_diagram_parser/metadata_extractor'
require_relative 'ddd_diagram_parser/parser'
