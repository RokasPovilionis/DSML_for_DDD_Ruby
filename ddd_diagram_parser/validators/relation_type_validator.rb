# frozen_string_literal: true

require_relative '../validation_report'

module DddDiagramParser
  module Validators
    # R4: Every edge must have relation_type
    class RelationTypeValidator
      # Validate that all edges have a relation_type
      # @param model [Model] the parsed model
      # @param report [ValidationReport] the report to add issues to
      def validate(model, report)
        model.edges.each do |edge|
          next unless edge.relation_type.nil? || edge.relation_type.strip.empty?

          source = model.node(edge.source_id)
          target = model.node(edge.target_id)

          report.add_error(
            code: 'R4_MISSING_RELATION_TYPE',
            message: 'Edge must have a relation_type property',
            node_id: edge.id,
            node_name: "#{source&.ddd_name || edge.source_id} -> #{target&.ddd_name || edge.target_id}"
          )
        end
      end
    end
  end
end
