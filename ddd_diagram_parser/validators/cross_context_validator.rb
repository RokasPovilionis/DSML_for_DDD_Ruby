# frozen_string_literal: true

require_relative '../validation_report'

module DddDiagramParser
  module Validators
    # R14: Detect cross-bounded-context links
    # - Integration relationships: OK across BCs
    # - Composition and association: ERROR across BCs
    # - Uses: WARNING across BCs (depends on style)
    class CrossContextValidator
      # Validate cross-bounded-context relationships
      # @param model [Model] the parsed model
      # @param report [ValidationReport] the report to add issues to
      def validate(model, report)
        model.edges.each do |edge|
          validate_cross_context_edge(edge, model, report)
        end
      end

      private

      def validate_cross_context_edge(edge, model, report)
        source = model.node(edge.source_id)
        target = model.node(edge.target_id)

        return unless source && target

        source_bc = get_bounded_context(source)
        target_bc = get_bounded_context(target)

        # Skip if either doesn't have a BC (other validators will catch this)
        return unless source_bc && target_bc

        # Skip if in same BC
        return if source_bc == target_bc

        # We have a cross-BC relationship
        case edge.relation_type
        when 'integration'
          # Integration across BCs is expected and OK
          # No warning or error needed
        when 'composition', 'association'
          # Composition and association should not cross BC boundaries
          report.add_error(
            code: 'R14_CROSS_CONTEXT_COMPOSITION',
            message: "#{edge.relation_type} relationship crosses bounded context boundaries (#{source_bc} → #{target_bc}). Composition/association should not cross BC boundaries.",
            node_id: edge.id,
            node_name: "#{source.ddd_name} -> #{target.ddd_name}"
          )
        when 'uses'
          # Uses across BCs is sometimes acceptable but should be noted
          report.add_warning(
            code: 'R14_CROSS_CONTEXT_USES',
            message: "Uses relationship crosses bounded context boundaries (#{source_bc} → #{target_bc}). Consider if this coupling is necessary.",
            node_id: edge.id,
            node_name: "#{source.ddd_name} -> #{target.ddd_name}"
          )
        when 'publishes_event', 'consumes_event'
          # Events can cross BC boundaries - this is a common pattern
          # But we might want to warn about it
          report.add_warning(
            code: 'R14_CROSS_CONTEXT_EVENT',
            message: "Event relationship crosses bounded context boundaries (#{source_bc} → #{target_bc}). Ensure this is intentional inter-context communication.",
            node_id: edge.id,
            node_name: "#{source.ddd_name} -> #{target.ddd_name}"
          )
        when 'repository_access'
          # Repository access should definitely not cross BCs
          report.add_error(
            code: 'R14_CROSS_CONTEXT_REPOSITORY',
            message: "Repository access crosses bounded context boundaries (#{source_bc} → #{target_bc}). Services should only access repositories in their own BC.",
            node_id: edge.id,
            node_name: "#{source.ddd_name} -> #{target.ddd_name}"
          )
        end
      end

      # Get the bounded context for a node
      # For most nodes this is the bounded_context property
      # For bounded contexts themselves, it's their own name
      def get_bounded_context(node)
        if node.ddd_type == 'bounded_context'
          node.ddd_name
        else
          node['bounded_context']
        end
      end
    end
  end
end
