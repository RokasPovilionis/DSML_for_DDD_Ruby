# frozen_string_literal: true

require_relative '../validation_report'

module DddDiagramParser
  module Validators
    # R8: Repository access must be Service → Repository
    class RepositoryAccessValidator
      # Validate repository_access relationships
      # @param model [Model] the parsed model
      # @param report [ValidationReport] the report to add issues to
      def validate(model, report)
        repo_edges = model.edges.select { |e| e.relation_type == 'repository_access' }

        repo_edges.each do |edge|
          source = model.node(edge.source_id)
          target = model.node(edge.target_id)

          # Skip if nodes don't exist
          next unless source && target

          # Source must be application_service or domain_service
          unless %w[application_service domain_service].include?(source.ddd_type)
            report.add_error(
              code: 'R8_INVALID_REPOSITORY_ACCESS_SOURCE',
              message: "Repository access source must be application_service or domain_service, found '#{source.ddd_type}'",
              node_id: edge.id,
              node_name: "#{source.ddd_name} -> #{target.ddd_name}"
            )
          end

          # Target must be repository
          next if target.ddd_type == 'repository'

          report.add_error(
            code: 'R8_INVALID_REPOSITORY_ACCESS_TARGET',
            message: "Repository access target must be repository, found '#{target.ddd_type}'",
            node_id: edge.id,
            node_name: "#{source.ddd_name} -> #{target.ddd_name}"
          )
        end
      end
    end
  end
end
