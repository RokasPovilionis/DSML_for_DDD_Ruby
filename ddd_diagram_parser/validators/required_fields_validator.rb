# frozen_string_literal: true

require_relative '../validation_report'

module DddDiagramParser
  module Validators
    # R1: Each DSML node must have ddd_type and ddd_name
    # Error if missing. Applies to all ddd_type nodes.
    class RequiredFieldsValidator
      # Validate that all nodes have required fields
      # @param model [Model] the parsed model
      # @param report [ValidationReport] the report to add issues to
      def validate(model, report)
        model.nodes.each do |node|
          validate_node(node, report)
        end
      end

      private

      def validate_node(node, report)
        # R1: Check for ddd_type
        if node.ddd_type.nil? || node.ddd_type.strip.empty?
          report.add_error(
            code: 'R1_MISSING_DDD_TYPE',
            message: 'Node must have a ddd_type property',
            node_id: node.id,
            node_name: node.ddd_name || 'unnamed'
          )
        end

        # R1: Check for ddd_name
        return unless node.ddd_name.nil? || node.ddd_name.strip.empty?

        report.add_error(
          code: 'R1_MISSING_DDD_NAME',
          message: 'Node must have a ddd_name property',
          node_id: node.id,
          node_name: node.ddd_type || 'unknown type'
        )
      end
    end
  end
end
