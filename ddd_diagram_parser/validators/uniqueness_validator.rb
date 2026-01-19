# frozen_string_literal: true

require_relative '../validation_report'

module DddDiagramParser
  module Validators
    # R2: ddd_name uniqueness within scope
    # - Bounded Context names must be unique (global scope)
    # - Within one BC: Aggregate, Service, Event names must be unique
    class UniquenessValidator
      # Validate uniqueness constraints
      # @param model [Model] the parsed model
      # @param report [ValidationReport] the report to add issues to
      def validate(model, report)
        validate_bounded_context_uniqueness(model, report)
        validate_within_bounded_context_uniqueness(model, report)
      end

      private

      # Bounded Context names must be unique globally
      def validate_bounded_context_uniqueness(model, report)
        bounded_contexts = model.nodes_by_type('bounded_context')
        names = Hash.new { |h, k| h[k] = [] }

        bounded_contexts.each do |bc|
          next if bc.ddd_name.nil? || bc.ddd_name.strip.empty?

          names[bc.ddd_name] << bc
        end

        names.each do |name, nodes|
          next if nodes.one?

          nodes.each do |node|
            report.add_error(
              code: 'R2_DUPLICATE_BOUNDED_CONTEXT',
              message: "Bounded Context name '#{name}' must be unique (found #{nodes.count} instances)",
              node_id: node.id,
              node_name: node.ddd_name
            )
          end
        end
      end

      # Within each Bounded Context, validate uniqueness of:
      # - Aggregate names
      # - Service names (application_service, domain_service)
      # - Event names (domain_event)
      def validate_within_bounded_context_uniqueness(model, report)
        # Group nodes by bounded_context
        nodes_by_bc = model.nodes.group_by { |n| n['bounded_context'] }

        nodes_by_bc.each do |bc_name, nodes|
          next if bc_name.nil? || bc_name.strip.empty?

          validate_aggregate_uniqueness(bc_name, nodes, report)
          validate_service_uniqueness(bc_name, nodes, report)
          validate_event_uniqueness(bc_name, nodes, report)
        end
      end

      def validate_aggregate_uniqueness(bc_name, nodes, report)
        aggregates = nodes.select { |n| n.ddd_type == 'aggregate_root' }
        check_name_uniqueness(
          aggregates,
          bc_name,
          'Aggregate',
          'R2_DUPLICATE_AGGREGATE',
          report
        )
      end

      def validate_service_uniqueness(bc_name, nodes, report)
        services = nodes.select do |n|
          %w[application_service domain_service].include?(n.ddd_type)
        end
        check_name_uniqueness(
          services,
          bc_name,
          'Service',
          'R2_DUPLICATE_SERVICE',
          report
        )
      end

      def validate_event_uniqueness(bc_name, nodes, report)
        events = nodes.select { |n| n.ddd_type == 'domain_event' }
        check_name_uniqueness(
          events,
          bc_name,
          'Domain Event',
          'R2_DUPLICATE_EVENT',
          report
        )
      end

      def check_name_uniqueness(nodes, bc_name, type_label, error_code, report)
        names = Hash.new { |h, k| h[k] = [] }

        nodes.each do |node|
          next if node.ddd_name.nil? || node.ddd_name.strip.empty?

          names[node.ddd_name] << node
        end

        names.each do |name, node_list|
          next if node_list.one?

          node_list.each do |node|
            report.add_error(
              code: error_code,
              message: "#{type_label} name '#{name}' must be unique within Bounded Context '#{bc_name}' (found #{node_list.count} instances)",
              node_id: node.id,
              node_name: node.ddd_name
            )
          end
        end
      end
    end
  end
end
