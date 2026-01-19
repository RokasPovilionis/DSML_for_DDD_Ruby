# frozen_string_literal: true

require_relative '../validation_report'

module DddDiagramParser
  module Validators
    # R9: Integration must target ExternalSystem
    class IntegrationValidator
      # Validate integration relationships
      # @param model [Model] the parsed model
      # @param report [ValidationReport] the report to add issues to
      def validate(model, report)
        integration_edges = model.edges.select { |e| e.relation_type == 'integration' }

        integration_edges.each do |edge|
          source = model.node(edge.source_id)
          target = model.node(edge.target_id)

          # Skip if nodes don't exist
          next unless source && target

          # Target must be external_system
          unless target.ddd_type == 'external_system'
            report.add_error(
              code: 'R9_INVALID_INTEGRATION_TARGET',
              message: "Integration target must be external_system, found '#{target.ddd_type}'",
              node_id: edge.id,
              node_name: "#{source.ddd_name} -> #{target.ddd_name}"
            )
          end

          # Source should typically be application_service or bounded_context
          # This is a softer constraint - we'll issue a warning for other types
          next if %w[application_service bounded_context].include?(source.ddd_type)

          report.add_warning(
            code: 'R9_UNUSUAL_INTEGRATION_SOURCE',
            message: "Integration source is typically application_service or bounded_context, found '#{source.ddd_type}'",
            node_id: edge.id,
            node_name: "#{source.ddd_name} -> #{target.ddd_name}"
          )
        end
      end
    end
  end
end
