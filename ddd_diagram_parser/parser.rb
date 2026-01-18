# frozen_string_literal: true

require_relative 'xml_parser'
require_relative 'metadata_extractor'
require_relative 'model'
require_relative 'node'
require_relative 'edge'

module DddDiagramParser
  # Main entry point for parsing Draw.io files into DSML Model
  # Orchestrates XML parsing, metadata extraction, and graph building
  class Parser
    # Parse a Draw.io file and return a Model
    # @param file_path [String] path to .drawio or .drawio.xml file
    # @param diagram_index [Integer] which diagram to parse (default: 0, first diagram)
    # @return [Model] parsed DSML model
    def self.parse(file_path, diagram_index: 0)
      new(file_path).parse(diagram_index: diagram_index)
    end

    # @param file_path [String] path to .drawio or .drawio.xml file
    def initialize(file_path)
      @file_path = file_path
    end

    # Parse the file and build the model
    # @param diagram_index [Integer] which diagram to parse
    # @return [Model]
    def parse(diagram_index: 0)
      # Step 1: Parse XML and extract cells
      diagrams = XmlParser.parse_file(@file_path)

      if diagrams.empty?
        raise "No diagrams found in #{@file_path}"
      end

      if diagram_index >= diagrams.length
        raise "Diagram index #{diagram_index} out of range (found #{diagrams.length} diagrams)"
      end

      diagram_data = diagrams[diagram_index]

      # Step 2: Build model from cells
      build_model(diagram_data)
    end

    # Parse all diagrams in the file
    # @return [Array<Model>] array of parsed models
    def parse_all
      diagrams = XmlParser.parse_file(@file_path)
      diagrams.map { |diagram_data| build_model(diagram_data) }
    end

    private

    # Build a Model from diagram data
    # @param diagram_data [Hash] diagram data from XmlParser
    # @return [Model]
    def build_model(diagram_data)
      model = Model.new(diagram_name: diagram_data[:name])

      # Separate cells into nodes and edges
      nodes_data = []
      edges_data = []

      diagram_data[:cells].each do |cell|
        # Skip root cells (id="0" or id="1")
        next if %w[0 1].include?(cell[:id])

        # Skip decorative elements (cells with parent that is not "1" and no metadata)
        if cell[:parent] && cell[:parent] != '1' && cell[:metadata].empty?
          next
        end

        if cell[:edge]
          edges_data << cell
        elsif cell[:vertex]
          nodes_data << cell
        end
      end

      # Build nodes
      nodes_data.each do |cell|
        node = build_node(cell)
        model.add_node(node) if node
      end

      # Build edges
      edges_data.each do |cell|
        edge = build_edge(cell)
        model.add_edge(edge) if edge
      end

      model
    end

    # Build a Node from cell data
    # @param cell [Hash] cell data
    # @return [Node, nil]
    def build_node(cell)
      # Extract metadata
      metadata = MetadataExtractor.extract(cell)

      # Create node
      Node.new(
        id: cell[:id],
        ddd_type: metadata['ddd_type'],
        ddd_name: metadata['ddd_name'],
        props: metadata,
        raw_label: metadata['raw_label'] || ''
      )
    end

    # Build an Edge from cell data
    # @param cell [Hash] cell data
    # @return [Edge, nil]
    def build_edge(cell)
      # Skip edges without source or target
      return nil unless cell[:source] && cell[:target]

      # Extract metadata
      metadata = MetadataExtractor.extract(cell)

      # Create edge
      Edge.new(
        id: cell[:id],
        relation_type: metadata['relation_type'],
        source_id: cell[:source],
        target_id: cell[:target],
        props: metadata,
        raw_label: metadata['raw_label'] || ''
      )
    end
  end
end
