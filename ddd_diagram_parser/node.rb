# frozen_string_literal: true

module DddDiagramParser
  # Represents a node (vertex) in the DSML diagram
  # Corresponds to DDD concepts like BoundedContext, Aggregate, Entity, etc.
  class Node
    attr_reader :id, :ddd_type, :ddd_name, :props, :raw_label

    # @param id [String] unique identifier from Draw.io
    # @param ddd_type [String, nil] DSML type (e.g., 'bounded_context', 'aggregate_root')
    # @param ddd_name [String, nil] DSML name
    # @param props [Hash] all metadata properties
    # @param raw_label [String] the original label text from Draw.io
    def initialize(id:, ddd_type: nil, ddd_name: nil, props: {}, raw_label: '')
      @id = id
      @ddd_type = ddd_type
      @ddd_name = ddd_name
      @props = props
      @raw_label = raw_label
    end

    # Get a specific property value
    # @param key [String, Symbol] property key
    # @return [Object, nil] property value
    def [](key)
      @props[key.to_s]
    end

    # Check if node has a specific property
    # @param key [String, Symbol] property key
    # @return [Boolean]
    def has_property?(key)
      @props.key?(key.to_s)
    end

    # Get all property keys
    # @return [Array<String>]
    def property_keys
      @props.keys
    end

    # String representation for debugging
    # @return [String]
    def to_s
      "<Node id=#{@id} type=#{@ddd_type || 'unknown'} name=#{@ddd_name || 'unnamed'}>"
    end

    # Hash representation
    # @return [Hash]
    def to_h
      {
        id: @id,
        ddd_type: @ddd_type,
        ddd_name: @ddd_name,
        props: @props,
        raw_label: @raw_label
      }
    end
  end
end
