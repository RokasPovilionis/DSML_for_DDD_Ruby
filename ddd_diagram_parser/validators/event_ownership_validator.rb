# frozen_string_literal: true

require_relative '../validation_report'

module DddDiagramParser
  module Validators
    # R13: Domain event must belong to exactly one BC
    # - bounded_context property required
    # - Warning if not published by any aggregate
    # - Error if published by multiple aggregates (strict ownership)
    class EventOwnershipValidator
      # Validate domain event ownership
      # @param model [Model] the parsed model
      # @param report [ValidationReport] the report to add issues to
      def validate(model, report)
        events = model.nodes_by_type('domain_event')

        events.each do |event|
          validate_event_ownership(event, model, report)
        end
      end

      private

      def validate_event_ownership(event, model, report)
        bc_name = event['bounded_context']

        # Check bounded_context property
        if bc_name.nil? || bc_name.to_s.strip.empty?
          report.add_error(
            code: 'R13_MISSING_BOUNDED_CONTEXT',
            message: "Domain event '#{event.ddd_name}' must belong to a bounded context (missing 'bounded_context' property)",
            node_id: event.id,
            node_name: event.ddd_name
          )
          return
        end

        # Check if the referenced BC exists
        bc_node = model.nodes_by_name(bc_name).find { |n| n.ddd_type == 'bounded_context' }

        unless bc_node
          report.add_error(
            code: 'R13_INVALID_BOUNDED_CONTEXT',
            message: "Domain event '#{event.ddd_name}' references non-existent bounded context '#{bc_name}'",
            node_id: event.id,
            node_name: event.ddd_name
          )
          return
        end

        # Check publishing aggregates
        publish_edges = model.edges.select do |e|
          e.relation_type == 'publishes_event' && e.target_id == event.id
        end

        publishing_aggregates = publish_edges.map do |edge|
          model.node(edge.source_id)
        end.compact.select { |n| n.ddd_type == 'aggregate_root' }

        if publishing_aggregates.empty?
          report.add_warning(
            code: 'R13_EVENT_NOT_PUBLISHED',
            message: "Domain event '#{event.ddd_name}' is not published by any aggregate",
            node_id: event.id,
            node_name: event.ddd_name
          )
        elsif publishing_aggregates.count > 1
          aggregate_names = publishing_aggregates.map(&:ddd_name).join(', ')
          report.add_error(
            code: 'R13_MULTIPLE_EVENT_PUBLISHERS',
            message: "Domain event '#{event.ddd_name}' is published by multiple aggregates (#{aggregate_names}). Events should have single ownership.",
            node_id: event.id,
            node_name: event.ddd_name
          )
        end
      end
    end
  end
end
