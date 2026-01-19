# frozen_string_literal: true

require_relative '../validation_report'

module DddDiagramParser
  module Validators
    # R12: Aggregate belongs to exactly one Bounded Context
    # - bounded_context property must exist
    # - bounded_context must reference an existing BC
    class BoundedContextMembershipValidator
      # Validate aggregate bounded context membership
      # @param model [Model] the parsed model
      # @param report [ValidationReport] the report to add issues to
      def validate(model, report)
        aggregates = model.nodes_by_type('aggregate_root')

        aggregates.each do |aggregate|
          validate_bc_membership(aggregate, model, report)
        end
      end

      private

      def validate_bc_membership(aggregate, model, report)
        bc_name = aggregate['bounded_context']

        if bc_name.nil? || bc_name.to_s.strip.empty?
          report.add_error(
            code: 'R12_MISSING_BOUNDED_CONTEXT',
            message: "Aggregate '#{aggregate.ddd_name}' must belong to a bounded context (missing 'bounded_context' property)",
            node_id: aggregate.id,
            node_name: aggregate.ddd_name
          )
          return
        end

        # Check if the referenced BC exists
        bc_node = model.nodes_by_name(bc_name).find { |n| n.ddd_type == 'bounded_context' }

        return if bc_node

        report.add_error(
          code: 'R12_INVALID_BOUNDED_CONTEXT',
          message: "Aggregate '#{aggregate.ddd_name}' references non-existent bounded context '#{bc_name}'",
          node_id: aggregate.id,
          node_name: aggregate.ddd_name
        )
      end
    end
  end
end
