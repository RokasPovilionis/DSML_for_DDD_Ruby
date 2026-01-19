# frozen_string_literal: true

module DddDiagramParser
  # Extracts DSML metadata from Draw.io cell data
  # Handles normalization of property names and values
  class MetadataExtractor
    # DSML property keys we recognize
    KNOWN_PROPERTIES = %w[
      ddd_type
      ddd_name
      bounded_context
      bonded_context
      context_key
      aggregate
      id_type
      rails_resource
      exposed_as
      relation_type
      kind
    ].freeze

    # Extract metadata from a cell hash
    # @param cell [Hash] raw cell data from XmlParser
    # @return [Hash] normalized metadata
    def self.extract(cell)
      new(cell).extract
    end

    # @param cell [Hash] raw cell data
    def initialize(cell)
      @cell = cell
    end

    # Extract and normalize metadata
    # @return [Hash] normalized metadata hash
    def extract
      metadata = {}

      # First, get metadata from the metadata hash (from <object> attributes)
      @cell[:metadata]&.each do |key, value|
        normalized_key = normalize_key(key)
        metadata[normalized_key] = normalize_value(value) if normalized_key
      end

      # Fix common typos (bonded_context -> bounded_context)
      if metadata['bonded_context'] && !metadata['bounded_context']
        metadata['bounded_context'] = metadata['bonded_context']
        metadata.delete('bonded_context')
      end

      # Extract label/value for raw_label
      metadata['raw_label'] = extract_label(@cell[:value]) || ''

      metadata
    end

    private

    # Normalize property key (convert to snake_case, handle variations)
    # @param key [String] property key
    # @return [String, nil] normalized key or nil if not a DSML property
    def normalize_key(key)
      key_lower = key.to_s.downcase.strip

      # Direct match
      return key_lower if KNOWN_PROPERTIES.include?(key_lower)

      # Handle common variations
      case key_lower
      when 'type', 'dddtype'
        'ddd_type'
      when 'name', 'dddname'
        'ddd_name'
      when 'context', 'bc'
        'bounded_context'
      when 'agg'
        'aggregate'
      when 'idtype', 'id'
        'id_type'
      when 'relation', 'relationtype', 'rel_type'
        'relation_type'
      else
        # Keep unknown properties as-is (might be custom extensions)
        key_lower
      end
    end

    # Normalize property value (trim, convert booleans, etc.)
    # @param value [String] property value
    # @return [Object] normalized value
    def normalize_value(value)
      return nil if value.nil?

      str_value = value.to_s.strip

      # Convert boolean strings
      case str_value.downcase
      when 'true', 'yes', '1'
        true
      when 'false', 'no', '0'
        false
      else
        str_value
      end
    end

    # Extract clean label text from HTML-formatted Draw.io label
    # @param label [String, nil] raw label from Draw.io
    # @return [String, nil] clean text
    def extract_label(label)
      return nil if label.nil? || label.empty?

      # Remove HTML tags (simple regex approach)
      clean = label.gsub(/<[^>]+>/, ' ')

      # Decode common HTML entities
      clean = clean.gsub('&lt;', '<')
                   .gsub('&gt;', '>')
                   .gsub('&amp;', '&')
                   .gsub('&quot;', '"')
                   .gsub('&nbsp;', ' ')

      # Clean up whitespace
      clean.gsub(/\s+/, ' ').strip
    end
  end
end
