# frozen_string_literal: true

require_relative '../validation_report'

module DddDiagramParser
  module Validators
    # R7: Consumes event must be DomainEvent → (ApplicationService or DomainService)
    class ConsumesEventValidator
      # Validate consumes_event relationships
      # @param model [Model] the parsed model
      # @param report [ValidationReport] the report to add issues to
      def validate(model, report)
        consumes_edges = model.edges.select { |e| e.relation_type == 'consumes_event' }

        consumes_edges.each do |edge|
          source = model.node(edge.source_id)
          target = model.node(edge.target_id)

          # Skip if nodes don't exist
          next unless source && target

          # Source must be domain_event
          unless source.ddd_type == 'domain_event'
            report.add_error(
              code: 'R7_INVALID_CONSUMES_SOURCE',
              message: "Consumes event source must be domain_event, found '#{source.ddd_type}'",
              node_id: edge.id,
              node_name: "#{source.ddd_name} -> #{target.ddd_name}"
            )
          end

          # Target must be application_service or domain_service
          next if %w[application_service domain_service].include?(target.ddd_type)

          report.add_error(
            code: 'R7_INVALID_CONSUMES_TARGET',
            message: "Consumes event target must be application_service or domain_service, found '#{target.ddd_type}'",
            node_id: edge.id,
            node_name: "#{source.ddd_name} -> #{target.ddd_name}"
          )
        end
      end
    end
  end
end
