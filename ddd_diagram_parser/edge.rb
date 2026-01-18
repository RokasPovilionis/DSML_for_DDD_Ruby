# frozen_string_literal: true

module DddDiagramParser
  # Represents an edge (connection) in the DSML diagram
  # Corresponds to DDD relationships like composition, uses, publishes, etc.
  class Edge
    attr_reader :id, :relation_type, :source_id, :target_id, :props, :raw_label

    # @param id [String] unique identifier from Draw.io
    # @param relation_type [String, nil] type of relationship (e.g., 'uses', 'composition')
    # @param source_id [String] id of the source node
    # @param target_id [String] id of the target node
    # @param props [Hash] all metadata properties
    # @param raw_label [String] the original label text from Draw.io
    def initialize(id:, source_id:, target_id:, relation_type: nil, props: {}, raw_label: '')
      @id = id
      @relation_type = relation_type
      @source_id = source_id
      @target_id = target_id
      @props = props
      @raw_label = raw_label
    end

    # Get a specific property value
    # @param key [String, Symbol] property key
    # @return [Object, nil] property value
    def [](key)
      @props[key.to_s]
    end

    # Check if edge has a specific property
    # @param key [String, Symbol] property key
    # @return [Boolean]
    def has_property?(key)
      @props.key?(key.to_s)
    end

    # String representation for debugging
    # @return [String]
    def to_s
      "<Edge id=#{@id} type=#{@relation_type || 'unknown'} #{@source_id} -> #{@target_id}>"
    end

    # Hash representation
    # @return [Hash]
    def to_h
      {
        id: @id,
        relation_type: @relation_type,
        source_id: @source_id,
        target_id: @target_id,
        props: @props,
        raw_label: @raw_label
      }
    end
  end
end
