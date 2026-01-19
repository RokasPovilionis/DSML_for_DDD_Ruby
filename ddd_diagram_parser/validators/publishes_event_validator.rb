# frozen_string_literal: true

require_relative '../validation_report'

module DddDiagramParser
  module Validators
    # R6: Publishes event must be AggregateRoot → DomainEvent
    class PublishesEventValidator
      # Validate publishes_event relationships
      # @param model [Model] the parsed model
      # @param report [ValidationReport] the report to add issues to
      def validate(model, report)
        publishes_edges = model.edges.select { |e| e.relation_type == 'publishes_event' }

        publishes_edges.each do |edge|
          source = model.node(edge.source_id)
          target = model.node(edge.target_id)

          # Skip if nodes don't exist
          next unless source && target

          # Source must be aggregate_root
          unless source.ddd_type == 'aggregate_root'
            report.add_error(
              code: 'R6_INVALID_PUBLISHES_SOURCE',
              message: "Publishes event source must be aggregate_root, found '#{source.ddd_type}'",
              node_id: edge.id,
              node_name: "#{source.ddd_name} -> #{target.ddd_name}"
            )
          end

          # Target must be domain_event
          next if target.ddd_type == 'domain_event'

          report.add_error(
            code: 'R6_INVALID_PUBLISHES_TARGET',
            message: "Publishes event target must be domain_event, found '#{target.ddd_type}'",
            node_id: edge.id,
            node_name: "#{source.ddd_name} -> #{target.ddd_name}"
          )
        end
      end
    end
  end
end
