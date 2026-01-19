# frozen_string_literal: true

require_relative '../validation_report'

module DddDiagramParser
  module Validators
    # R11: Entity and Value Object must belong to an Aggregate Root
    # - Error if both property and composition edge are missing
    # - Warning if only one exists (property without edge, or edge without property)
    class AggregateOwnershipValidator
      # Validate entity/value object ownership
      # @param model [Model] the parsed model
      # @param report [ValidationReport] the report to add issues to
      def validate(model, report)
        entities_and_vos = model.nodes.select do |n|
          %w[entity value_object].include?(n.ddd_type)
        end

        entities_and_vos.each do |node|
          validate_ownership(node, model, report)
        end
      end

      private

      def validate_ownership(node, model, report)
        has_property = !node['aggregate'].nil? && !node['aggregate'].to_s.strip.empty?
        aggregate_from_property = has_property ? node['aggregate'] : nil

        # Check if there's a composition edge pointing to this node
        composition_edges = model.edges.select do |e|
          e.relation_type == 'composition' && e.target_id == node.id
        end

        has_composition_edge = !composition_edges.empty?

        # Validate the aggregate referenced in property exists
        if has_property
          aggregate_node = model.nodes_by_name(aggregate_from_property)
                                .find { |n| n.ddd_type == 'aggregate_root' }

          unless aggregate_node
            report.add_error(
              code: 'R11_INVALID_AGGREGATE_REFERENCE',
              message: "#{node.ddd_type} '#{node.ddd_name}' references non-existent aggregate '#{aggregate_from_property}'",
              node_id: node.id,
              node_name: node.ddd_name
            )
            return
          end

          # Check if composition edge matches the property
          if has_composition_edge
            source_aggregate = model.node(composition_edges.first.source_id)
            if source_aggregate && source_aggregate.ddd_name != aggregate_from_property
              report.add_warning(
                code: 'R11_AGGREGATE_MISMATCH',
                message: "#{node.ddd_type} '#{node.ddd_name}' has aggregate property '#{aggregate_from_property}' but composition from '#{source_aggregate.ddd_name}'",
                node_id: node.id,
                node_name: node.ddd_name
              )
            end
          else
            # Has property but no composition edge
            report.add_warning(
              code: 'R11_MISSING_COMPOSITION_EDGE',
              message: "#{node.ddd_type} '#{node.ddd_name}' has aggregate property but no composition edge from aggregate",
              node_id: node.id,
              node_name: node.ddd_name
            )
          end
        elsif has_composition_edge
          # Has composition edge but no property
          source_aggregate = model.node(composition_edges.first.source_id)
          report.add_warning(
            code: 'R11_MISSING_AGGREGATE_PROPERTY',
            message: "#{node.ddd_type} '#{node.ddd_name}' has composition edge but no 'aggregate' property (should be '#{source_aggregate&.ddd_name}')",
            node_id: node.id,
            node_name: node.ddd_name
          )
        else
          # Neither property nor composition edge
          report.add_error(
            code: 'R11_MISSING_AGGREGATE_OWNERSHIP',
            message: "#{node.ddd_type} '#{node.ddd_name}' must belong to an aggregate (missing both 'aggregate' property and composition edge)",
            node_id: node.id,
            node_name: node.ddd_name
          )
        end
      end
    end
  end
end
