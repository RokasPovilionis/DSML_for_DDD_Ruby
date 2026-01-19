# frozen_string_literal: true

require_relative '../validation_report'

module DddDiagramParser
  module Validators
    # R10: Uses must not point to "illegal" types
    # Allowed targets: aggregates, services, repositories
    # Disallowed: value_objects, events (for strictness)
    class UsesValidator
      ALLOWED_TARGETS = %w[
        aggregate_root
        application_service
        domain_service
        repository
      ].freeze

      DISALLOWED_TARGETS = %w[
        value_object
        domain_event
      ].freeze

      # Validate uses relationships
      # @param model [Model] the parsed model
      # @param report [ValidationReport] the report to add issues to
      def validate(model, report)
        uses_edges = model.edges.select { |e| e.relation_type == 'uses' }

        uses_edges.each do |edge|
          source = model.node(edge.source_id)
          target = model.node(edge.target_id)

          # Skip if nodes don't exist
          next unless source && target

          # Check if target is explicitly disallowed
          if DISALLOWED_TARGETS.include?(target.ddd_type)
            report.add_error(
              code: 'R10_ILLEGAL_USES_TARGET',
              message: "Uses cannot target #{target.ddd_type}, allowed targets: #{ALLOWED_TARGETS.join(', ')}",
              node_id: edge.id,
              node_name: "#{source.ddd_name} -> #{target.ddd_name}"
            )
          elsif !ALLOWED_TARGETS.include?(target.ddd_type)
            # Warn for unusual targets
            report.add_warning(
              code: 'R10_UNUSUAL_USES_TARGET',
              message: "Uses targeting '#{target.ddd_type}' is unusual, recommended targets: #{ALLOWED_TARGETS.join(', ')}",
              node_id: edge.id,
              node_name: "#{source.ddd_name} -> #{target.ddd_name}"
            )
          end
        end
      end
    end
  end
end
