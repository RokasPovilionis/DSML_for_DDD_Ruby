# frozen_string_literal: true

require_relative '../validation_report'

module DddDiagramParser
  module Validators
    # R5: Composition must be AggregateRoot → (Entity or ValueObject)
    class CompositionValidator
      # Validate composition relationships
      # @param model [Model] the parsed model
      # @param report [ValidationReport] the report to add issues to
      def validate(model, report)
        composition_edges = model.edges.select { |e| e.relation_type == 'composition' }

        composition_edges.each do |edge|
          source = model.node(edge.source_id)
          target = model.node(edge.target_id)

          # Skip if nodes don't exist
          next unless source && target

          # Source must be aggregate_root
          unless source.ddd_type == 'aggregate_root'
            report.add_error(
              code: 'R5_INVALID_COMPOSITION_SOURCE',
              message: "Composition source must be aggregate_root, found '#{source.ddd_type}'",
              node_id: edge.id,
              node_name: "#{source.ddd_name} -> #{target.ddd_name}"
            )
          end

          # Target must be entity or value_object
          next if %w[entity value_object].include?(target.ddd_type)

          report.add_error(
            code: 'R5_INVALID_COMPOSITION_TARGET',
            message: "Composition target must be entity or value_object, found '#{target.ddd_type}'",
            node_id: edge.id,
            node_name: "#{source.ddd_name} -> #{target.ddd_name}"
          )
        end
      end
    end
  end
end
