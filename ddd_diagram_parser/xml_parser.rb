# frozen_string_literal: true

require 'nokogiri'

module DddDiagramParser
  # Handles low-level parsing of Draw.io XML files
  # Extracts mxCells and their attributes from mxGraphModel
  class XmlParser
    # Parse a Draw.io file and extract all diagrams
    # @param file_path [String] path to .drawio or .drawio.xml file
    # @return [Array<Hash>] array of diagrams, each containing mxCells
    def self.parse_file(file_path)
      new(file_path).parse
    end

    # @param file_path [String] path to .drawio or .drawio.xml file
    def initialize(file_path)
      @file_path = file_path
    end

    # Parse the file and return diagrams
    # @return [Array<Hash>] array of diagram data
    def parse
      doc = load_xml
      extract_diagrams(doc)
    end

    private

    # Load and parse XML document
    # @return [Nokogiri::XML::Document]
    def load_xml
      file_content = File.read(@file_path)
      Nokogiri::XML(file_content)
    end

    # Extract all diagrams from mxfile
    # @param doc [Nokogiri::XML::Document]
    # @return [Array<Hash>]
    def extract_diagrams(doc)
      diagrams = []

      doc.xpath('//mxfile/diagram').each do |diagram_element|
        diagram_data = {
          id: diagram_element['id'],
          name: diagram_element['name'] || 'Untitled',
          cells: []
        }

        # Get the mxGraphModel
        graph_model = diagram_element.at_xpath('./mxGraphModel')
        next unless graph_model

        # Extract all cells from the root
        root_element = graph_model.at_xpath('./root')
        next unless root_element

        root_element.children.each do |element|
          next unless element.element?

          if element.name == 'mxCell'
            diagram_data[:cells] << extract_cell(element)
          elsif element.name == 'object'
            # Draw.io uses <object> wrapper for cells with custom data
            diagram_data[:cells] << extract_object_cell(element)
          end
        end

        diagrams << diagram_data
      end

      diagrams
    end

    # Extract data from a plain mxCell element
    # @param cell_element [Nokogiri::XML::Element]
    # @return [Hash]
    def extract_cell(cell_element)
      # Determine if vertex or edge
      # Draw.io sets vertex="1" or edge="1" explicitly
      # If neither is set but source/target exist, it's an edge
      # Otherwise, if it has a style and parent, it's likely a vertex
      is_edge = cell_element['edge'] == '1' ||
                (cell_element['source'] && cell_element['target'])
      is_vertex = cell_element['vertex'] == '1' ||
                  (!is_edge && cell_element['style'])

      {
        id: cell_element['id'],
        value: cell_element['value'],
        style: cell_element['style'],
        vertex: is_vertex,
        edge: is_edge,
        parent: cell_element['parent'],
        source: cell_element['source'],
        target: cell_element['target'],
        metadata: {}
      }
    end

    # Extract data from an <object> element (which wraps mxCell with metadata)
    # @param object_element [Nokogiri::XML::Element]
    # @return [Hash]
    def extract_object_cell(object_element)
      # Get the nested mxCell
      cell_element = object_element.at_xpath('./mxCell')

      # Start with basic cell data
      cell_data = if cell_element
                    extract_cell(cell_element)
                  else
                    # Fallback if no mxCell child exists
                    # Use the object's id
                    {
                      id: object_element['id'],
                      value: nil,
                      style: nil,
                      vertex: false,
                      edge: false,
                      parent: nil,
                      source: nil,
                      target: nil,
                      metadata: {}
                    }
                  end

      # Override ID to use object's ID (more reliable)
      cell_data[:id] = object_element['id']

      # Extract custom metadata from object attributes
      metadata = {}
      object_element.attribute_nodes.each do |attr|
        key = attr.name
        value = attr.value

        # Skip standard Draw.io attributes
        next if %w[id label].include?(key)

        # All other attributes are DSML metadata
        metadata[key] = value
      end

      # Label is often on the object element
      cell_data[:value] = object_element['label'] if object_element['label']

      # Merge cell data with metadata
      cell_data[:metadata] = metadata
      cell_data
    end
  end
end
