# frozen_string_literal: true

require_relative '../validation_report'

module DddDiagramParser
  module Validators
    # R3: Required properties by type
    # Each DDD element type has specific required properties
    class RequiredPropertiesValidator
      # Schema defining required properties for each ddd_type
      REQUIRED_PROPERTIES = {
        'bounded_context' => ['context_key'],
        'aggregate_root' => %w[bounded_context id_type],
        'entity' => %w[aggregate id_type],
        'value_object' => ['aggregate'],
        'application_service' => ['bounded_context'],
        'domain_service' => ['bounded_context'],
        'repository' => ['aggregate'],
        'external_system' => ['kind']
      }.freeze

      # Validate required properties for each node type
      # @param model [Model] the parsed model
      # @param report [ValidationReport] the report to add issues to
      def validate(model, report)
        model.nodes.each do |node|
          validate_node(node, report)
        end
      end

      private

      def validate_node(node, report)
        # Skip if node doesn't have a type (will be caught by R1)
        return if node.ddd_type.nil? || node.ddd_type.strip.empty?

        required_props = REQUIRED_PROPERTIES[node.ddd_type]

        # If this type has no required properties, skip
        return if required_props.nil?

        required_props.each do |prop|
          validate_property(node, prop, report)
        end
      end

      def validate_property(node, property, report)
        value = node[property]

        return unless value.nil? || (value.is_a?(String) && value.strip.empty?)

        report.add_error(
          code: 'R3_MISSING_REQUIRED_PROPERTY',
          message: "#{node.ddd_type} '#{node.ddd_name}' must have '#{property}' property",
          node_id: node.id,
          node_name: node.ddd_name
        )
      end
    end
  end
end
